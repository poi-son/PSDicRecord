//
//  PSNSDateConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/2.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSNSDateConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSNSDateConvertor()
@property(nonatomic, retain) NSDate *signature;
@end

@implementation PSNSDateConvertor
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
    return NSDate.class;
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
    sqlite3_bind_double(statement, idx, [obj timeIntervalSince1970]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
        memcpy(buffer, (void *)&date, sizeof(id));
        return date;
    }else if ([obj isKindOfClass:[NSDate class]]){
        memcpy(buffer, (void *)&obj, sizeof(id));
        return nil;
    }
    PSAssert(NO, @"can not conver <%@ %p>:%@ to NSDate", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    return obj;
}
@end
