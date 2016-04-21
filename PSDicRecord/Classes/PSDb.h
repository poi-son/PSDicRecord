//
//  PSDb.h
//  PSExtensions
//
//  Created by PoiSon on 15/9/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSRecord.h"

NS_ASSUME_NONNULL_BEGIN
@class PSPage<M>;
@class PSSql;

/**
 *  PSDb
 *  <p/>
 *  Professional database query and update tool.
 */
@interface PSDb : NSObject
- (NSString *)configName;/**< Return config name of current datasource */
+ (instancetype)use:(nullable NSString *)configName;/**< Change default datasource. Use default datasource if nil. */
+ (instancetype)main;/**< Use main datasource. */

- (nullable id)queryOne:(NSString *)sql, ...;/**< Execute sql query just return one column.*/
- (nullable id)queryOneWithSql:(PSSql *)sql;/**< Execute sql query just return one column.*/
- (BOOL)update:(NSString *)sql, ...;/**< Execute update, insert or delete sql statement. */
- (BOOL)updateWithSql:(PSSql *)sql;/**< Execute update, insert or delete sql statement. */
- (BOOL)tx:(BOOL (^)(PSDb *db))transaction;/**< Execute transaction. */
- (BOOL)batch:(NSArray<NSString *> *)sqls;/**< Execute a batch of sqls. */
- (BOOL)batchSqls:(NSArray<PSSql *> *)sqls;/**< Execute a batch of sqls. */
/**
 *  Paginate.
 *
 *  @param pageIndex the page index, start with 1
 *  @param pageSize  the page size
 *  @param select    the select part of the sql statement
 *  @param where     the sql statement excluded select part and the parameters of sql.
 *
 *  @return PSPage<PSRecord *> *
 */
- (PSPage<PSRecord *> *)paginate:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where, ...;
@end

@interface PSDb(Record)
- (NSArray<PSRecord *> *)find:(NSString *)sql, ...;/**< Find records. */
- (NSArray<PSRecord *> *)findWithSql:(PSSql *)sql;/**< Find records. */
- (nullable PSRecord *)findFirst:(NSString *)sql, ...;/**< Find first record. I recommend add "limit 1" in your sql. */
- (nullable PSRecord *)findFirstWithSql:(PSSql *)sql;/**< Find first record. I recommend add "limit 1" in your sql. */
@end
NS_ASSUME_NONNULL_END
