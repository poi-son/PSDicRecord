//
//  PSLongLongConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSLongLongConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSLongLongConvertor()
@property(nonatomic, assign) long long signature;
@end

@implementation PSLongLongConvertor
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
    sqlite3_bind_int64(statement, idx, [obj longLongValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        long long value = [obj longLongValue];
        memcpy(buffer, &value, sizeof(long long));
        return [NSNumber numberWithLongLong:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        long long value = [obj longLongValue];
        memcpy(buffer, &value, sizeof(long long));
        return strcmp([obj objCType], @encode(long long)) == 0 ? nil : [NSNumber numberWithLongLong:value];
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to long long", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    long long value;
    memcpy(&value, buffer, sizeof(long long));
    return [NSNumber numberWithLongLong:value];
}
@end
