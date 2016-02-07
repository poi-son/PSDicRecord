//
//  PSSQLBuilder.m
//  PSExtensions
//
//  Created by PoiSon on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"

@implementation PSSqlBuilder
+ (PSSql *)forCreate:(PSTable *)table{
    NSMutableString *createSql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT", table.name];
    for (PSColumn *column in table.cols) {
        continueIf([column.name.lowercaseString isEqualToString:@"ID".lowercaseString]);
        [createSql appendFormat:@", %@ %@", column.name, column.convertor.dataType];
        
        NSString *columnProperty = [table.type propertyForColumn:column.name];
        if (columnProperty.length > 0) {
            [createSql appendFormat:@" %@", columnProperty];
        }
    }
    [createSql appendString:@")"];
    return [PSSql buildSql:createSql];
}

+ (PSSql *)forAddColumn:(PSColumn *)column toTable:(PSTable *)table{
    NSMutableString *addSql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", table.name, column.name, column.convertor.dataType];
    NSString *columnProperty = [table.type propertyForColumn:column.name];
    if (columnProperty.length > 0) {
        [addSql appendFormat:@" %@", columnProperty];
    }
    return [PSSql buildSql:addSql];
}

+ (PSSql *)forRowCount:(PSTable *)table byCondition:(NSString *)condition withArgs:(NSArray<id> *)args{
    NSMutableString *rowCountSql = [NSMutableString stringWithFormat:@"SELECT COUNT(1) FROM %@", table.name];
    if (condition.length > 0) {
        [rowCountSql appendString:@" WHERE "];
        [rowCountSql appendString:condition];
    }
    return [PSSql buildSql:rowCountSql withArgs:args];
}

+ (PSSql *)forSave:(PSTable *)table attrs:(id<PSDictionaryProtocol>)attrs{
    NSMutableArray *params = [NSMutableArray new];
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", table.name];
    NSMutableString *args = [[NSMutableString alloc] initWithString:@") VALUES("];
    BOOL isFirst = YES;
    for (NSString *attrKey in attrs) {
        continueIf(![table hasColumn:attrKey]);

        if (!isFirst) {
            [sqlStr appendString:@", "];
            [args appendString:@", "];
        }
        [sqlStr appendString:attrKey];
        [args appendString:@"?"];
        [params addObject:[attrs valueForKey:attrKey]];
        isFirst = NO;
    }
    [sqlStr appendString:args];
    [sqlStr appendString:@")"];
    return [PSSql buildSql:sqlStr withArgs:params];
}

+ (PSSql *)forUpdate:(PSTable *)table attrs:(id<PSDictionaryProtocol>)attrs modifyFlag:(NSSet<NSString *> *)modifyFlags{
    NSMutableArray *params = [NSMutableArray new];
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", table.name];
    
    BOOL isUpdatable = NO;
    for (NSString *modifyColumn in modifyFlags) {
        continueIf(![table hasColumn:modifyColumn]);
        continueIf([table.key isEqualToString:modifyColumn]);
        
        doIf(isUpdatable, [sqlStr appendString:@", "]);
        
        [sqlStr appendFormat:@"%@ = ?", modifyColumn];
        [params addObject:[attrs valueForKey:modifyColumn]];
        isUpdatable = YES;
    }
    
    PSAssert(isUpdatable, @"none attrs are updatable.");
    
    [sqlStr appendFormat:@" WHERE %@ = ?", table.key];
    id idValue = [attrs valueForKey:table.key];
    PSAssert(idValue, @"can't find primark key in model.");
    [params addObject:idValue];
    
    return [PSSql buildSql:sqlStr withArgs:params];
}

+ (PSSql *)forReplace:(PSTable *)table attrs:(id<PSDictionaryProtocol>)attrs{
    NSMutableArray *params = [NSMutableArray new];
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"REPLACE INTO %@ (", table.name];
    NSMutableString *args = [[NSMutableString alloc] initWithString:@") VALUES("];
    BOOL isFirst = YES;
    for (NSString *attrKey in attrs) {
        continueIf(![table hasColumn:attrKey]);
        
        if (!isFirst) {
            [sqlStr appendString:@", "];
            [args appendString:@", "];
        }
        
        [sqlStr appendString:attrKey];
        [args appendString:@"?"];
        [params addObject:[attrs valueForKey:attrKey]];
        isFirst = NO;
    }
    [sqlStr appendString:args];
    [sqlStr appendString:@")"];
    return [PSSql buildSql:sqlStr withArgs:params];
}

+ (PSSql *)forDelete:(PSTable *)table byCondition:(NSString *)condition withArgs:(NSArray<id> *)args{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@", table.name];
    if (condition.length) {
        [sql appendString:@" WHERE "];
        [sql appendString:condition];
    }
    return [PSSql buildSql:sql withArgs:args];
}

+ (PSSql *)forFind:(PSTable *)table columns:(NSString *)columns byCondition:(NSString *)condition withArgs:(NSArray<id> *)args{
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
    if (columns.length > 0) {
        [sql appendString:columns];
    }else{
        NSMutableString *cols = [NSMutableString new];
        for (PSColumn *column in table.cols) {
            doIf(cols.length, [cols appendString:@", "]);
            [cols appendFormat:@"%@", column.name];
        }
        
        [sql appendString:cols];
    }
    [sql appendFormat:@" FROM %@", table.name];
    
    if (condition.length > 0) {
        [sql appendFormat:@" WHERE %@", condition];
    }
    return [PSSql buildSql:sql withArgs:args];
}

+ (PSSql *)forPaginateIndex:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where args:(NSArray *)args{
    NSInteger offset = pageSize * (pageIndex - 1);
    NSString *sql = [NSString stringWithFormat:@"%@ %@ LIMIT %@ OFFSET %@", select, where, @(pageSize), @(offset)];
    return [PSSql buildSql:sql withArgs:args];
}
@end
