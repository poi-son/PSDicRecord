//
//  assert.m
//  PSDicRecord
//
//  Created by yan on 16/2/7.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import "assert.h"
#import "objc.h"

@implementation PSSqlException
+ (NSException *)exceptionInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line description:(NSString *)desc, ...{
    va_list va;
    va_start(va, desc);
    va_end(va);
    NSString *description = [[NSString alloc] initWithFormat:desc arguments:va];
    
    NSString *fileName = [@(file) lastPathComponent];
    
    sql_printf(@"%@ %@: %@\nPSDicRecord: %@\n", [[self formatter] stringFromDate:[NSDate date]], fileName, @(line), description);
    
    return [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:description
                                 userInfo:@{
                                            @"func": NSStringFromSelector(method),
                                            @"file": fileName,
                                            @"lineNumber": @(line)
                                            }];
}

+ (NSException *)exceptionInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line error:(NSString *)error code:(id)code sql:(id)sql datasource:(NSString *)datasource{
    NSString *fileName = [@(file) lastPathComponent];
    
    sql_printf(@"%@ %@: %@\nPSDicRecord: %@\n{\n   Error code: %@,\n   Sql: %@,\n   Datasource: %@\n}\n", [[self formatter] stringFromDate:[NSDate date]], fileName, @(line), error, code, sql, datasource);
    
    return [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:error
                                 userInfo:@{
                                            @"func": NSStringFromSelector(method),
                                            @"file": fileName,
                                            @"lineNumber": @(line)
                                            }];
}

+ (NSDateFormatter *)formatter{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
    });
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return formatter;
}
@end