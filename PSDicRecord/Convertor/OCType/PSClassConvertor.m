//
//  PSClassConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/2.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSClassConvertor.h"
#import "PSDicRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSClassConvertor()
@property(nonatomic, retain) Class signature;
@end

@implementation PSClassConvertor
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
    return NSString.class;
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
    sqlite3_bind_text(statement, idx, class_getName(obj), -1, SQLITE_STATIC);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    Class metaclass = object_getClass(obj);
    if (class_isMetaClass(metaclass)) {
        memcpy(buffer, (void *)&obj, sizeof(Class));
        return nil;
    }else if ([obj isKindOfClass:[NSString class]]){
        Class value = NSClassFromString(obj);
        if (value) {
            memcpy(buffer, (void *)&value, sizeof(Class));
            return value;
        }
    }
    
    PSAssert(NO, @"can not conver <%@ %p>:%@ to Class", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id value = nil;
    memcpy(&value, buffer, sizeof(Class));
    if (class_isMetaClass(object_getClass(value))) {
        return value;
    }else if ([value isKindOfClass:[NSString class]]){
        return NSClassFromString(value);
    }
    
    PSAssert(NO, @"can not conver <%@ %p> to Class", [value class], value);
    return value;
}

@end
