//
//  PSDbConnection.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/18.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary<NSString *, id> PSQueryResult;
typedef NSArray<NSDictionary<NSString *, id> *> PSQueryResultSet;
@class PSSql;
@protocol PSTypeConvertor;

NS_ASSUME_NONNULL_BEGIN
@interface PSDbConnection : NSObject
+ (void)showSqls:(BOOL)showSql;

@property (nonatomic, copy, readonly) NSString *datasource;
- (instancetype)initWithDatasource:(NSString *)datasource NS_DESIGNATED_INITIALIZER;

- (BOOL)open;/**< connect to database. */
- (BOOL)close;/**< disconnect to database.*/
- (BOOL)isClosed;/**< whether is closed. */
- (int)lastErrorCode;/**< last execution error code. */
- (nullable NSString *)lastErrorMessage;/**< last execution error message. */
@end

@class PSDbStatement;
/**
 *  Make prepared statement
 */
@interface PSDbConnection(Statement)
- (nullable PSDbStatement *)prepareStatement:(PSSql *)sql;
@end

@interface PSDbConnection(Transaction)
- (BOOL)isInTransaction;/**< whether currently in a transaction or not. */
- (void)beginTransaction;/**< Begin a transaction. */
- (void)commit;/**< Commit a transaction. */
- (void)rollback;/**< Rollback a transaction. */
@end

@interface PSDbStatement : NSObject
#pragma mark - query
- (PSQueryResultSet *)executeQuery;/**< execute querable sql. */

#pragma mark - update
- (BOOL)executeUpdate;/**< execute updatable sql. */
- (long long int)generatedKey;/**< get generated primary key when execute a insert sql. */
@end
NS_ASSUME_NONNULL_END