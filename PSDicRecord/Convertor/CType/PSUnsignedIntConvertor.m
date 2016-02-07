//
//  PSUnsignedIntConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSUnsignedIntConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSUnsignedIntConvertor()
@property(nonatomic, assign) unsigned int signature;
@end

@implementation PSUnsignedIntConvertor
- (NSString *)type{
    static NSString *_type = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_property_t property = class_getProperty(self.class, "signature");
        char *type = property_copyAttributeValue(property, "T");
        _type = @(type);
        free((void *)type);
    });
    return _type;
}

- (Class)objcType{
    return NSNumber.class;
}

- (NSString *)dataType{
    return PSSQLiteTypeINTEGER;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_int(statement, idx, [obj unsignedIntValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        long long llvalue = [obj longLongValue];
        unsigned int value = (unsigned int)llvalue;
        memcpy(buffer, &value, sizeof(unsigned int));
        return [NSNumber numberWithUnsignedInt:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        unsigned int value = [obj unsignedIntValue];
        memcpy(buffer, &value, sizeof(unsigned int));
        return strcmp([obj objCType], @encode(unsigned int)) == 0 ? nil : [NSNumber numberWithUnsignedInt:value];
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to unsigned int", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    unsigned int value;
    memcpy(&value, buffer, sizeof(unsigned int));
    return [NSNumber numberWithUnsignedInt:value];
}
@end
