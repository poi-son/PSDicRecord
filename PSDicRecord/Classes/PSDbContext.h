//
//  PSDbContext.h
//  PSDicRecord
//
//  Created by yan on 16/2/6.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSDicRecord/PSDicRecordDefines.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PSContainerFactory;
@protocol PSTypeConvertor;

@interface PSDbContext : NSObject
- (instancetype)init PSDICRECORD_API_UNAVAILABLE("use initWithDatasource:forConfig: instead");
+ (instancetype)new PSDICRECORD_API_UNAVAILABLE("use initWithDatasource:forConfig: instead");

- (instancetype)initWithDatasource:(NSString *)datasource;/**< user default config name 'main'. */
- (instancetype)initWithDatasource:(NSString *)datasource forConfig:(NSString *)configName NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL showSql;/**< Show sql to console. Default NO. */
@property (nonatomic, strong) id<PSContainerFactory> containerFactory;/**< Default return PSCaseSensitiveContainerFactory. */
@property (nonatomic, copy, readonly) NSString *configName;/**< Config name. */
@property (nonatomic, copy, readonly) NSString *datasource;/**< File of sqlite database. Create database file if not exists. */

- (void)registerModel:(Class)model;/**< Register model to context. */
- (void)registerConvertor:(id<PSTypeConvertor>)convertor;/** Register type convertor to context. */
- (void)initialize;/**< Initialize this context. */
@end

NS_ASSUME_NONNULL_END