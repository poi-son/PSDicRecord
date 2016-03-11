//
//  PSLongConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSLongConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSLongConvertor()
@property(nonatomic, assign) long signature;
@end

@implementation PSLongConvertor
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
    sqlite3_bind_int64(statement, idx, [obj longValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        long long llvalue = [obj longLongValue];
        long value = (long)llvalue;
        memcpy(buffer, &value, sizeof(long));
        return [NSNumber numberWithLong:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        long value = [obj longValue];
        memcpy(buffer, &value, sizeof(long));
        return strcmp([obj objCType], @encode(long)) == 0 ? nil : [NSNumber numberWithLong:value];
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to long", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    long value;
    memcpy(&value, buffer, sizeof(long));
    return [NSNumber numberWithLong:value];
}
@end
