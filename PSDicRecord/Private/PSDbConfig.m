//
//  PSDbConfig.m
//  PSExtensions
//
//  Created by PoiSon on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"

@interface PSDbConfig()

@end

@implementation PSDbConfig{
    /** thread safe transaction connection*/
    PSDbConnection *_transConnection;
    PSDbConnection *_connection;
    NSRecursiveLock *_lock;
}

- (instancetype)initWithName:(NSString *)name datasource:(NSString *)datasource showSql:(BOOL)showSql{
    if (self = [super init]) {
        _name = [name copy];
        _datasource = [datasource copy];
        _showSql = showSql;
        _transConnection = nil;
        _lock = [NSRecursiveLock new];
        _connection = [[PSDbConnection alloc] initWithDatasource:_datasource];
//        doIf(_showSql, [PSAspect interceptSelector:@selector(prepareStatement:) inInstance:_connection withInterceptor:self]);
    }
    return self;
}

- (id<PSContainerFactory>)containerFactory{
    return _containerFactory?: [PSCaseSensitiveContainerFactory new];
}

// log sql
- (void)intercept:(NSInvocation *)invocation{
//    __unsafe_unretained PSSql *sql;
//    [invocation getArgument:&sql atIndex:2];
//    PSPrintf(@"%@ PSDicRecord:\n%@\n=========================================\n", [[NSDate new] ps_toString:@"yyyy-MM-dd HH:mm:ss.SSS"], [sql debugDescription]);
//    [invocation invoke];
}

- (PSDbConnection *)getOpenedConnection{
    [_lock lock];
    PSAssert(_connection, @"can not open sqlite, please check whether if PSDicRecord started.");
    [_connection open];
    return _connection;
}

- (void)setTransactionConnection:(PSDbConnection *)connection{
    PSAssert(!_transConnection, @"can not reopen a transaction.");
    _transConnection = connection;
}

- (void)removeTransactionConnection{
    _transConnection = nil;
}

- (void)close:(PSDbConnection *)conn{
    @try {
        if (_transConnection == nil) {
            PSAssert([conn close], @"can not close connection: %@.", conn);
        }
    }
    @finally {
        [_lock unlock];
    }
}

- (BOOL)isInTransaction{
    return _transConnection != nil;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<PSDbConfig %p>:\n{\n   name : %@\n   containerFactory : %@\n   isInTransaction : %@\n   datasource : %@\n}\n", self, self.name, NSStringFromClass([self.containerFactory class]), self.isInTransaction ?@"YES": @"NO", self.datasource];
}
@end
