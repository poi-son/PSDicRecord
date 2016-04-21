//
//  PSUnsignedLongLongConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSUnsignedLongLongConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSUnsignedLongLongConvertor()
@property(nonatomic, assign) unsigned long long signature;
@end

@implementation PSUnsignedLongLongConvertor
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
    sqlite3_bind_int64(statement, idx, [obj unsignedLongLongValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        long long llvalue = [obj longLongValue];
        unsigned long long value = (unsigned long long)llvalue;
        memcpy(buffer, &value, sizeof(unsigned long long));
        return [NSNumber numberWithUnsignedLongLong:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        unsigned long long value = [obj unsignedLongLongValue];
        memcpy(buffer, &value, sizeof(unsigned long long));
        return strcmp([obj objCType], @encode(unsigned long long)) == 0 ? nil : [NSNumber numberWithUnsignedLongLong:value];
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to unsigned long long", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    unsigned long long value;
    memcpy(&value, buffer, sizeof(unsigned long long));
    return [NSNumber numberWithUnsignedLongLong:value];
}
@end
