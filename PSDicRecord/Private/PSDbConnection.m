//
//  PSDbConnection.m
//  PSExtensions
//
//  Thanks for FMDB, some codes are from FMDB
//
//  Created by PoiSon on 15/10/18.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"
#import <sqlite3.h>

@interface PSDbStatement(Init)
- (instancetype)initWithSql:(NSString *)sql statement:(sqlite3_stmt *)statement connection:(PSDbConnection *)connection;
- (void)close;
@end

@interface PSDbConnection(){
    sqlite3 *_db;
    BOOL _isInTransaction;
}

@end

@implementation PSDbConnection
- (instancetype)init{
    return [self initWithDatasource:@""];
}

- (instancetype)initWithDatasource:(NSString *)datasource{
    if (self = [super init]) {
        _datasource = datasource;
    }
    return self;
}

- (sqlite3 *)handler{
    return _db;
}

- (BOOL)open{
    returnValIf(_db, YES);
    
    int result = sqlite3_open([self.datasource UTF8String], &_db);
    PSDbAssert(result == SQLITE_OK, @"open failed", nil, nil, self.datasource);
    
    return YES;
}

- (BOOL)close{
    returnValIf(!_db, YES);
    
    BOOL retry;
    do {
        retry = NO;
        int result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            sqlite3_stmt *pStmt;
            while ((pStmt = sqlite3_next_stmt(_db, nil))) {
                sql_printf(@"PSDicRecord: Closing leaked statement");
                sqlite3_finalize(pStmt);
                retry = YES;
            }
        }else if (result != SQLITE_OK){
            sql_printf(@"PSDicRecord: Close statement failed\n{\n   Datasource: %@\n}", self.datasource);
        }
    } while (retry);
    _db = nil;
    return YES;
}

- (BOOL)isClosed{
    return !(_db);
}

- (int)lastErrorCode{
    return sqlite3_errcode(_db);
}

- (NSString *)lastErrorMessage{
    return [NSString stringWithUTF8String:sqlite3_errmsg(_db)];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<PSDbConnection %p>:\n{\n   Status : %@,\n   Datasource : %@\n}", self, [self isClosed]? @"Closed": @"Opened", [self datasource]];
}
@end

@implementation PSDbConnection(Statement)
- (PSDbStatement *)prepareStatement:(PSSql *)sql{
    PSParameterAssert(sql != nil && sql.sql.length > 0);
    
    int result              = 0x00;
    sqlite3_stmt *statement = 0x00;
    
    result = sqlite3_prepare_v2(_db, [sql.sql UTF8String], -1, &statement, 0);
    if (result != SQLITE_OK) {
        sqlite3_finalize(statement);
        PSDbAssert(NO, self.lastErrorMessage, @(result), sql, self.datasource);
    }

    int bindedParamCount = 0;
    int paramCount = sqlite3_bind_parameter_count(statement);
    
    if (sql.args.count) {
        while (bindedParamCount < paramCount) {
            id obj = nil;
            if (sql.args.count > bindedParamCount) {
                obj = [sql.args objectAtIndex:bindedParamCount];
            }
            bindedParamCount ++;
            [self bindObject:obj toColumn:bindedParamCount inStatement:statement];
        }
    }
    
    PSDbAssert(bindedParamCount == paramCount, @"arguments count is less than required count.", nil, sql, self.datasource);
    
    return [[PSDbStatement alloc] initWithSql:sql.sql statement:statement connection:self];
}


- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)pStmt{
    // FIXME - someday check the return codes on these binds.
    if ((!obj) || [obj isKindOfClass:[NSNull class]]) {
        sqlite3_bind_null(pStmt, idx);
    }else{
        id<PSTypeConvertor> convertor = [PSDbKit convertorForObject:obj];
        [convertor bindObject:obj toColumn:idx inStatement:pStmt];
    }
}
@end

#pragma mark - PSDbConnection Transaction
@implementation PSDbConnection (Transaction)
- (BOOL)isInTransaction{
    return self->_isInTransaction;
}

- (void)beginTransaction{
    PSDbAssert(!self.isInTransaction, @"Should not repeat beginning a transaction.", nil, nil, self.datasource);
    PSDbAssert([[self prepareStatement:[PSSql buildSql:@"begin exclusive transaction"]] executeUpdate], self.lastErrorMessage, nil, nil, self.datasource);
    self->_isInTransaction = YES;
}

- (void)commit{
    PSDbAssert(self.isInTransaction, @"Should begin a transaction before commit.", nil, nil, self.datasource);
    PSDbAssert([[self prepareStatement:[PSSql buildSql:@"commit transaction"]] executeUpdate], self.lastErrorMessage, nil, nil, self.datasource);
    self->_isInTransaction = NO;
}

- (void)rollback{
    PSDbAssert(self.isInTransaction, @"Should begin a transaction before rollback.", nil, nil, self.datasource);
    PSDbAssert([[self prepareStatement:[PSSql buildSql:@"rollback transaction"]] executeUpdate], self.lastErrorMessage, nil, nil, self.datasource);
    self->_isInTransaction = NO;
}
@end

#pragma mark - PSDbStatement
@implementation PSDbStatement{
    sqlite3_stmt *_statement;
    NSString *_sql;
    PSDbConnection *_connection;
}

- (instancetype)initWithSql:(NSString *)sql statement:(sqlite3_stmt *)statement connection:(PSDbConnection *)connection{
    if (self = [super init]) {
        _statement = statement;
        _connection = connection;
        _sql = [sql copy];
    }
    return self;
}


#pragma mark - executeQuery
- (PSQueryResultSet *)executeQuery{
    NSMutableArray *set = [NSMutableArray new];
    while ([self hasNext]) {
        NSUInteger num_cols = (NSUInteger)sqlite3_data_count(_statement);
        continueIf(num_cols < 1);
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (int idx = 0; idx < num_cols; idx ++) {
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(_statement, idx)];
            id objectValue = [self valueForColumnIndex:idx];
            [result setObject:objectValue forKey:columnName];
        }
        [set addObject:result];
    }
    [self close];
    return set;
}

- (BOOL)hasNext{
    int result = sqlite3_step(_statement);
    switch (result) {
        case SQLITE_DONE:
        case SQLITE_OK:
        case SQLITE_ROW:
            //all is well
            break;
        case SQLITE_BUSY:
        case SQLITE_LOCKED:
            sql_printf(@"PSDicRecord: Database is busy\n{\n   Error: %@\n   Result Code: %@\n   Sql: %@\n   Datasource: %@\n}\n", _connection.lastErrorMessage, @(result), _sql, _connection.datasource);
            break;
        case SQLITE_ERROR:
        case SQLITE_MISUSE:
            sql_printf(@"PSDicRecord: Error calling sqlite3_step\n{\n   Error: %@\n   Result Code: %@\n   Sql: %@\n   Datasource: %@\n}", _connection.lastErrorMessage, @(result), _sql, _connection.datasource);
            break;
        default:
            sql_printf(@"PSDicRecord: Unknown error calling sqlite3_step\n{\n   Error: %@\n   Result Code: %@\n   Sql: %@\n   Datasource: %@\n}\n", _connection.lastErrorMessage, @(result), _sql, _connection.datasource);
            break;
    }
    
    doIf(result != SQLITE_ROW, [self close]);
    
    return result == SQLITE_ROW;
}

- (id)valueForColumnIndex:(int)columnIdx{
    int columnType = sqlite3_column_type(_statement, columnIdx);
    id result = nil;
    switch (columnType) {
        case SQLITE_INTEGER:
            result = [NSNumber numberWithLongLong:sqlite3_column_int64(_statement, columnIdx)];
            break;
        case SQLITE_FLOAT:
            result = [NSNumber numberWithDouble:sqlite3_column_double(_statement, columnIdx)];
            break;
        case SQLITE_BLOB:{
            const char *dataBuffer = sqlite3_column_blob(_statement, columnIdx);
            int dataSize = sqlite3_column_bytes(_statement, columnIdx);
            breakIf(dataBuffer == NULL);
            result = [NSData dataWithBytes:dataBuffer length:dataSize];
        }
            break;
        case SQLITE_TEXT:{
            const char *c = (const char *)sqlite3_column_text(_statement, columnIdx);
            breakIf(c == NULL);
            result = [NSString stringWithUTF8String:c];
        }
            break;
        case SQLITE_NULL:
            result = [NSNull null];
            break;
        default:
            break;
    }

    return result ?: [NSNull null];
}
#pragma mark - executeUpdate
- (BOOL)executeUpdate{
    int result = sqlite3_step(_statement);
    switch (result) {
        case SQLITE_ERROR:
        case SQLITE_MISUSE:
            sql_printf(@"PSDicRecord: Error calling sqlite3_step\n{\n   Error: %@\n   Result Code: %@\n   Sql: %@\n   Datasource: %@\n}\n", _connection.lastErrorMessage, @(result), _sql, _connection.datasource);
            break;
        case SQLITE_ROW:
            PSDbAssert(NO, @"A executeUpdate is being called with a query string", nil, _sql, _connection.datasource);
            break;
        default:
            break;
    }
    [self close];
    
    return result == SQLITE_DONE || result == SQLITE_OK;
}

- (long long int)generatedKey{
    sqlite_int64 result = sqlite3_last_insert_rowid([_connection handler]);
    return result;
}

- (void)close{
    sqlite3_finalize(_statement);
    _statement = nil;
}

- (void)dealloc{
    [self close];
}
@end