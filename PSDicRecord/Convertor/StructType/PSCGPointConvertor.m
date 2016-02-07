//
//  PSCGPointConvertor.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/11.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSCGPointConvertor.h"
#import "PSDicRecord_private.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <objc/runtime.h>

@interface PSCGPointConvertor()
@property(nonatomic, assign) CGPoint signature;
@end

@implementation PSCGPointConvertor
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
    return NSValue.class;
}

- (NSString *)dataType{
    return PSSQLiteTypeBLOG;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(NSValue *)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    sqlite3_bind_blob(statement, idx, [data bytes], (int)[data length], NULL);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    NSValue *value = obj;
    if ([value isKindOfClass:[NSData class]]) {
        value = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
    }
    if ([value isKindOfClass:[NSValue class]] && strcmp(@encode(CGPoint), [value objCType]) == 0) {
        CGPoint structValue = [value CGPointValue];
        memcpy(buffer, &structValue, sizeof(CGPoint));
        return [obj isKindOfClass:NSData.class] ? value : nil;
    }
    
    NSAssert(NO, @"can not conver <%@ %p>:%@ to CGPoint", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    CGPoint value;
    memcpy(&value, buffer, sizeof(CGPoint));
    return [NSValue valueWithCGPoint:value];
}
@end
