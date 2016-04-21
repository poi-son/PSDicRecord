//
//  assert.h
//  PSDicRecord
//
//  Created by yan on 16/2/7.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PSAssert(condition, desc, ...) \
    do { \
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (!(condition)) {		\
            @throw [PSDbError errorInMethod: _cmd \
                                     object: self \
                                       file: __FILE__ \
                                       line: __LINE__ \
                                description: desc, ##__VA_ARGS__]; \
        } \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#define PSParameterAssert(condition) PSAssert((condition), @"Invalid parameter not satisfying: %@", @#condition)

#define PSDbAssert(condition, err_msg, err_code, err_sql, err_ds) \
    do { \
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (!(condition)) {		\
            @throw [PSDbError errorInMethod: _cmd \
                                     object: self \
                                       file: __FILE__ \
                                       line: __LINE__ \
                                      error: err_msg \
                                       code: err_code \
                                        sql: err_sql \
                                 datasource: err_ds]; \
        } \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

@interface PSDbError : NSObject
+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line description:(NSString *)desc, ...;
+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line error:(NSString *)error code:(id)code sql:(id)sql datasource:(NSString *)datasource;
@end