//
//  assert.m
//  PSDicRecord
//
//  Created by yan on 16/2/7.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import "assert.h"
#import "objc.h"
#import "PSDicRecordDefines.h"

PSDICRECORD_EXTERN_STRING_IMP(PSDicRecordErrorFunction)
PSDICRECORD_EXTERN_STRING_IMP(PSDicRecordErrorFile)
PSDICRECORD_EXTERN_STRING_IMP(PSDicRecordErrorLine)

@implementation PSSqlError
+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line description:(NSString *)desc, ...{
    va_list va;
    va_start(va, desc);
    va_end(va);
    NSString *description = [[NSString alloc] initWithFormat:desc arguments:va];
    
    NSString *fileName = [@(file) lastPathComponent];
    
    sql_printf(@"%@ %@: %@\nPSDicRecord: %@\n", [[self formatter] stringFromDate:[NSDate date]], fileName, @(line), description);
    
    return [NSError errorWithDomain:@"cn.yerl.PSDicRecord"
                               code:-1000
                           userInfo:@{NSLocalizedDescriptionKey: description,
                                      PSDicRecordErrorFunction: NSStringFromSelector(method),
                                      PSDicRecordErrorFile: fileName,
                                      PSDicRecordErrorLine: @(line)}];
}

+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line error:(NSString *)error code:(id)code sql:(id)sql datasource:(NSString *)datasource{
    NSString *fileName = [@(file) lastPathComponent];
    
    sql_printf(@"%@ %@: %@\nPSDicRecord: %@\n{\n   Error code: %@,\n   Sql: %@,\n   Datasource: %@\n}\n", [[self formatter] stringFromDate:[NSDate date]], fileName, @(line), error, code, sql, datasource);
    
    return [NSError errorWithDomain:@"cn.yerl.PSDicRecord"
                               code:-1000
                           userInfo:@{NSLocalizedDescriptionKey: @"Excuting Error",
                                      PSDicRecordErrorFunction: NSStringFromSelector(method),
                                      PSDicRecordErrorFile: fileName,
                                      PSDicRecordErrorLine: @(line)}];
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