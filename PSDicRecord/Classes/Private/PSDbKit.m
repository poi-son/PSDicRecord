//
//  PSDbKit.m
//  PSExtensions
//
//  Created by PoiSon on 15/10/1.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"
#import "metamacros.h"
#import "PSConvertors.h"
#import <objc/runtime.h>

@implementation PSDbKit
+ (PSDbConfig *)brokenConfig{
    static PSDbConfig *_broken_config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _broken_config = [PSDbConfig new];
    });
    return _broken_config;
}

static PSDbConfig *mainConfig;
+ (PSDbConfig *)mainConfig{
    return mainConfig;
}

#pragma mark -
+ (NSMutableDictionary<NSString *, PSDbConfig *> *)nameToConfig{
    static NSMutableDictionary<NSString *, PSDbConfig *> *_nameToConfig = nil;
    return _nameToConfig ?: (_nameToConfig = [NSMutableDictionary new]);
}

+ (NSMutableDictionary<NSString *, PSDbConfig *> *)modelToConfig{
    static NSMutableDictionary<NSString *, PSDbConfig *> *_modelConfigMap = nil;
    return _modelConfigMap ?: (_modelConfigMap = [NSMutableDictionary new]);
}

+ (NSMutableDictionary<NSString *, PSTable *> *)nameToTable{
    static NSMutableDictionary<NSString *, PSTable *> *_nameTableMap = nil;
    return _nameTableMap ?: (_nameTableMap = [NSMutableDictionary new]);
}

+ (NSMutableDictionary<NSString *, PSTable *> *)modelToTable{
    static NSMutableDictionary<NSString *, PSTable *> *_modelTableMap = nil;
    return _modelTableMap ?: (_modelTableMap = [NSMutableDictionary new]);
}

+ (NSMutableSet<NSString *> *)datasources{
    static NSMutableSet<NSString *> *_datasources = nil;
    return _datasources ?: (_datasources = [NSMutableSet new]);
}

+ (void)addConfig:(PSDbConfig *)config{
    PSAssert(config, @"Config can not be null");
    PSAssert(![[self.nameToConfig allKeys]containsObject:config.name], @"Config already exists: ", config.name);
    PSAssert(![self.datasources containsObject:config.datasource], @"Datasource for %@ is already exists.", config.name);
    [self.datasources addObject:config.datasource];
    
    [self.nameToConfig setObject:config forKey:config.name.lowercaseString];
    
    if ([@"main" isEqualToString:config.name.lowercaseString]) {
        mainConfig = config;
    }
    
    if (!mainConfig) {
        mainConfig = config;
    }
}

+ (void)addModel:(Class)model toConfigMapping:(PSDbConfig *)config{
    [self.modelToConfig setObject:config forKey:NSStringFromClass(model)];
}

+ (void)addModel:(Class)model toTableMapping:(PSTable *)table{
    [self.modelToTable setObject:table forKey:NSStringFromClass(model)];
    [self.nameToTable setObject:table forKey:[table stringValueForKey:@"name"].lowercaseString];
}

+ (PSDbConfig *)configForName:(NSString *)configName{
    return [self.nameToConfig objectForKey:[configName lowercaseString]];
}

+ (PSDbConfig *)configForModel:(Class)model{
    return [self.modelToConfig objectForKey:NSStringFromClass(model)];
}

+ (PSTable *)tableForModel:(Class)model{
    return [self.modelToTable objectForKey:NSStringFromClass(model)];
}

+ (PSTable *)tableForName:(NSString *)tableName{
    return [self.nameToTable objectForKey:[tableName lowercaseString]];
}

#pragma mark -
+ (NSMutableSet<id<PSTypeConvertor>> *)convertors{
    static NSMutableSet<id<PSTypeConvertor>> *_convertors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet<id<PSTypeConvertor>> *set = [NSMutableSet new];
        
#define CONVERTOR(Type) metamacro_concat(metamacro_concat(PS, Type), Convertor)
#define REGISTER_CONVERTOR(Type) \
    [set addObject:[CONVERTOR(Type) new]];
        
        //CType
        REGISTER_CONVERTOR(Char);
        REGISTER_CONVERTOR(UnsignedChar);
        REGISTER_CONVERTOR(Short);
        REGISTER_CONVERTOR(UnsignedShort);
        REGISTER_CONVERTOR(Int);
        REGISTER_CONVERTOR(UnsignedInt);
        REGISTER_CONVERTOR(Long);
        REGISTER_CONVERTOR(UnsignedLong);
        REGISTER_CONVERTOR(LongLong);//not used in 64bit
        REGISTER_CONVERTOR(UnsignedLongLong);//not used in 64bit
        REGISTER_CONVERTOR(Float);
        REGISTER_CONVERTOR(Double);
        REGISTER_CONVERTOR(Bool);
        
        //OCType
        REGISTER_CONVERTOR(Class);
        REGISTER_CONVERTOR(NSData);
        REGISTER_CONVERTOR(NSDate);
        REGISTER_CONVERTOR(NSDecimalNumber);
        REGISTER_CONVERTOR(NSString);
        REGISTER_CONVERTOR(NSURL);
        REGISTER_CONVERTOR(NSValue);
        REGISTER_CONVERTOR(UIColor);
        
        //StructType
        REGISTER_CONVERTOR(CGAffineTransform);
        REGISTER_CONVERTOR(CGPoint);
        REGISTER_CONVERTOR(CGRect);
        REGISTER_CONVERTOR(CGSize);
        REGISTER_CONVERTOR(CGVector);
        REGISTER_CONVERTOR(UIEdgeInsets);
        REGISTER_CONVERTOR(UIOffset);
        REGISTER_CONVERTOR(NSRange);
        
#undef REGISTER_CONVERTOR
#undef CONVERTOR
        _convertors = set;
    });
    return _convertors;
}

+ (NSMapTable<NSString *, id<PSTypeConvertor>> *)typeConvertors{
    static NSMapTable<NSString *, id<PSTypeConvertor>> *_encode_convertor_map;
    return _encode_convertor_map ?: (_encode_convertor_map = ({
        NSMapTable<NSString *, id<PSTypeConvertor>> *map = [NSMapTable strongToWeakObjectsMapTable];
        for (id<PSTypeConvertor> convertor in self.convertors) {
            [map setObject:convertor forKey:convertor.type];
        }
        map;
    }));
}

+ (id<PSTypeConvertor>)convertorForType:(NSString *)typeEncoding{
    id<PSTypeConvertor> convertor = [self.typeConvertors objectForKey:typeEncoding];
    PSAssert(convertor, @"can not find suitable convertor for type: %@", typeEncoding);
    return convertor;
}

+ (id<PSTypeConvertor>)convertorForObject:(id)obj{
    static NSMapTable<NSString *, id<PSTypeConvertor>> *numberConvertorMap = nil;
    static NSMapTable<NSString *, id<PSTypeConvertor>> *valueConvertorMap = nil;
    static NSMapTable<NSString *, id<PSTypeConvertor>> *otherConvertorMap = nil;
    static __weak PSClassConvertor *classConvertor;//PSClassConvertor
    static NSMutableSet<Class> *otherTypes = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberConvertorMap = [NSMapTable strongToWeakObjectsMapTable];
        valueConvertorMap = [NSMapTable strongToWeakObjectsMapTable];
        otherConvertorMap = [NSMapTable strongToWeakObjectsMapTable];
        otherTypes = [NSMutableSet new];
        
        [self.convertors enumerateObjectsUsingBlock:^(id<PSTypeConvertor>  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj.objcType isSubclassOfClass:NSNumber.class]) {
                [numberConvertorMap setObject:obj forKey:obj.type];
            }else if ([obj.objcType isSubclassOfClass:NSValue.class]){
                [valueConvertorMap setObject:obj forKey:obj.type];
            }else{
                if (![obj isKindOfClass:[PSClassConvertor class]]) {
                    [otherConvertorMap setObject:obj forKey:NSStringFromClass(obj.objcType)];
                    [otherTypes addObject:obj.objcType];
                }else{
                    classConvertor = obj;
                }
            }
            
        }];
    });
    
    returnValIf(!obj, nil);
    
    id<PSTypeConvertor> convertor = nil;
    Class class = object_getClass(obj);
    
    if (class_isMetaClass(class)) {
        convertor = classConvertor;
    }else if ([class isSubclassOfClass:NSNumber.class]){
        NSString *key = [NSString stringWithUTF8String:[obj objCType]];
        convertor = [numberConvertorMap objectForKey:key];
    }else if ([class isSubclassOfClass:NSValue.class]){
        NSString *key = [NSString stringWithUTF8String:[obj objCType]];
        convertor = [valueConvertorMap objectForKey:key];
    }
    if (convertor == nil) {
        for (Class type in otherTypes) {
            if ([class isSubclassOfClass:type]) {
                convertor = [otherConvertorMap objectForKey:NSStringFromClass(type)];
                break;
            }
        }
    }
    
    PSAssert(convertor, @"can not find suitable convertor for obj:<%@ %p>", NSStringFromClass([obj class]), obj);
    return convertor;
}

+ (void)addConvertor:(id<PSTypeConvertor>)convertor{
    [self.convertors addObject:convertor];
}

@end
