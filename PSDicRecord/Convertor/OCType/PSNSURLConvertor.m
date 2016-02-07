//
//  PSNSURLConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/7.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSNSURLConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSNSURLConvertor()
@property(nonatomic, retain) NSURL *signature;
@end

@implementation PSNSURLConvertor
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
    return NSURL.class;
}

- (NSString *)dataType{
    return PSSQLiteTypeTEXT;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    NSString *value = [obj absoluteString];
    sqlite3_bind_text(statement, idx, [value UTF8String], -1, SQLITE_STATIC);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:NSString.class]) {
        NSURL *value = [NSURL URLWithString:obj];
        memcpy(buffer, (void *)&value, sizeof(id));
        return value;
    }else if ([obj isKindOfClass:NSURL.class]){
        memcpy(buffer, (void *)&obj, sizeof(id));
        return nil;
    }
    PSAssert(NO, @"can not conver <%@ %p> to NSDecimalNumber", [obj class], obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    return obj;
}

@end
