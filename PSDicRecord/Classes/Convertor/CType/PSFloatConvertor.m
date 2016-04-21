//
//  PSFloatConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSFloatConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSFloatConvertor()
@property(nonatomic, assign) float signature;
@end

@implementation PSFloatConvertor
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
    return PSSQLiteTypeREAL;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_double(statement, idx, [obj floatValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        float value = [obj floatValue];
        memcpy(buffer, &value, sizeof(float));
        return [NSNumber numberWithFloat:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        float value = [obj floatValue];
        memcpy(buffer, &value, sizeof(float));
        return strcmp([obj objCType], @encode(float)) == 0 ? nil : [NSNumber numberWithFloat:value];
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to float", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    float value;
    memcpy(&value, buffer, sizeof(float));
    return [NSNumber numberWithFloat:value];
}
@end
