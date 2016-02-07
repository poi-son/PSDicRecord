//
//  UnsignedShortConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/4.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSUnsignedShortConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSUnsignedShortConvertor ()
@property(nonatomic, assign) unsigned short signature;
@end

@implementation PSUnsignedShortConvertor
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
    sqlite3_bind_int(statement, idx, [obj unsignedShortValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        long long llvalue = [obj longLongValue];
        unsigned short value = (unsigned short)llvalue;
        memcpy(buffer, &value, sizeof(unsigned short));
        return [NSNumber numberWithUnsignedShort:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        unsigned short value = [obj unsignedShortValue];
        memcpy(buffer, &value, sizeof(unsigned short));
        return strcmp([obj objCType], @encode(unsigned short)) == 0 ? nil : [NSNumber numberWithUnsignedShort:value];
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to unsigned short", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    unsigned short value;
    memcpy(&value, buffer, sizeof(unsigned short));
    return [NSNumber numberWithUnsignedShort:value];
}
@end
