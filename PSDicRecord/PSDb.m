//
//  PSDb.m
//  PSExtensions
//
//  Created by PoiSon on 15/9/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"

@interface PSDb()
@end

@implementation PSDb{
    PSDbConfig *_config;
    PSDbConnection *_tansConn;
}

- (instancetype)initWithConfig:(PSDbConfig *)config{
    if (self = [super init]) {
        PSAssert(config, @"can not set up a nil config");
        _config = config;
    }
    return self;
}

- (instancetype)init{
    PSDbConfig *config = [PSDbKit mainConfig];
    PSAssert(config, @"The main config is nil, initialize PSDicRecord first");
    return [self initWithConfig:config];
}

+ (instancetype)use:(NSString *)configName{
    if (configName.length) {
        PSDbConfig *config = [PSDbKit configForName:configName];
        PSAssert(config, @"Config not found by configName: ", configName);
        return [[self alloc] initWithConfig:config];
    }else{
        return [self main];
    }
}

// singleton to prevent repeat allocation.
+ (instancetype)main{
    static PSDb *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (NSString *)configName{
    return _config.name;
}

#pragma mark -
- (id)queryOne:(NSString *)sql, ...{
    return [self queryOneWithSql:[PSSql buildSql:sql withArgs:va_array(sql)]];
}

- (id)queryOneWithSql:(PSSql *)sql{
    PSDbConnection *conn = [_config getOpenedConnection];
    @try {
        PSQueryResultSet *result = [[conn prepareStatement:sql] executeQuery];
        returnValIf(result.count < 1, nil);
        
        PSQueryResult *item = [result objectAtIndex:0];
        NSArray *values = [item allValues];
        PSAssert(values.count > 0, @"No columns was queried.");
        PSAssert(values.count < 2, @"Only ONE column can be queried.");
        return [values[0] isKindOfClass:[NSNull class]] ? nil : values[0];
    }
    @finally {
        [_config close:conn];
    }
}

- (BOOL)update:(NSString *)sql, ...{
    return [self updateWithSql:[PSSql buildSql:sql withArgs:va_array(sql)]];
}

- (BOOL)updateWithSql:(PSSql *)sql{
    PSDbConnection *conn = [_config getOpenedConnection];
    @try {
        return [[conn prepareStatement:sql] executeUpdate];
    }
    @finally {
        [_config close:conn];
    }
}

- (BOOL)tx:(BOOL (^)(PSDb *))transaction{
    PSDbConnection *conn = [_config getOpenedConnection];
    [_config setTransactionConnection:conn];
    [conn beginTransaction];
    BOOL result = NO;
    @try {
        result = transaction(self);
        if (result) {
            [conn commit];
        }else{
            [conn rollback];
        }
        return result;
    }
    @catch (id error) {
        [conn rollback];
        @throw error;
    }
    @finally {
        [_config removeTransactionConnection];
        [_config close:conn];
    }
}

- (BOOL)batch:(NSArray<NSString *> *)sqls{
    NSMutableArray<PSSql *> *sqlArray = [NSMutableArray new];
    for (NSString *sql in sqls) {
        [sqlArray addObject:[PSSql buildSql:sql]];
    }
    return [self batchSqls:sqlArray];
}

- (BOOL)batchSqls:(NSArray<PSSql *> *)sqls{
    if (sqls.count < 1) {
        return YES;
    }
    
    PSDbConnection *conn = [_config getOpenedConnection];
    BOOL isInTransaction = _config.isInTransaction;
    
    doIf(!isInTransaction, ({
        [_config setTransactionConnection:conn];
        [conn beginTransaction];
    }));
    
    @try {
        for (PSSql *sql in sqls) {
            PSAssert([[conn prepareStatement:sql] executeUpdate], conn.lastErrorMessage, nil);
        }
        doIf(!isInTransaction, [conn commit]);
        return YES;
    }
    @catch (id error) {
        doIf(!isInTransaction, [conn rollback]);
        @throw error;
    }
    @finally {
        doIf(!isInTransaction, ({
            [_config removeTransactionConnection];
        }));
        [_config close:conn];
    }
}

- (PSPage<PSRecord *> *)paginate:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where, ...{
    PSAssert(pageIndex > 0 && pageSize > 0, @"pageIndex and pageSize must be more than 0");
    
    NSInteger total;
    {
        total = [[self queryOneWithSql:[PSSql buildSql:[@"select count(1) " stringByAppendingString:where] withArgs:va_array(where)]] integerValue];
        returnValIf(total < 1, [PSPage pageWithArray:[NSArray new] index:0 size:0 total:0]);
    }
    
    PSSql *sql = [PSSqlBuilder forPaginateIndex:pageIndex size:pageSize withSelect:select where:where args:va_array(where)];
    NSArray<PSRecord *> *result = [self findWithSql:sql];
    return [PSPage pageWithArray:result index:pageIndex size:pageSize total:total];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<PSDb %p>:\n{\n   config name: %@\n   datasource: %@\n}", self, _config.name, _config.datasource];
}
@end

#pragma mark -
@implementation PSDb(Record)
- (NSArray<PSRecord *> *)find:(NSString *)sql, ...{
    return [self findWithSql:[PSSql buildSql:sql withArgs:va_array(sql)]];
}

- (NSArray<PSRecord *> *)findWithSql:(PSSql *)sql{
    PSDbConnection *conn = [_config getOpenedConnection];
    @try {
        PSQueryResultSet *result = [[conn prepareStatement:sql] executeQuery];
        NSMutableArray<PSRecord *> *records = [NSMutableArray new];
        [result enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [records addObject:[[PSRecord alloc] initWithAttributes:obj]];
        }];
        return records;
    }
    @finally {
        [_config close:conn];
    }
}

- (PSRecord *)findFirst:(NSString *)sql, ...{
    NSArray *result = [self findWithSql:[PSSql buildSql:sql withArgs:va_array(sql)]];
    returnValIf(result.count, result[0]);
    return nil;
}

- (PSRecord *)findFirstWithSql:(PSSql *)sql{
    NSArray *result = [self findWithSql:sql];
    returnValIf(result.count, result[0]);
    return nil;
}
@end
