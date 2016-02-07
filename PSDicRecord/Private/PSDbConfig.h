//
//  PSDbConfig.h
//  PSExtensions
//
//  Created by PoiSon on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSDbConnection;
@protocol PSContainerFactory;
NS_ASSUME_NONNULL_BEGIN
@interface PSDbConfig : NSObject
- (nonnull instancetype)initWithName:(nonnull NSString *)name datasource:(nonnull NSString *)datasource;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *datasource;
@property (nonatomic, strong) id<PSContainerFactory> containerFactory;

#pragma mark - Transaction
@property (nonatomic, assign, readonly) BOOL isInTransaction;
- (void)setTransactionConnection:(PSDbConnection *)connection;/**< set up a common connection to begin a transaction. */
- (void)removeTransactionConnection;/**< remove the common connection to complete a transaction. */
- (PSDbConnection *)getOpenedConnection;/**< get a connection, this connection may be a transaction connection. */
- (void)close:(PSDbConnection *)conn;/**< close a connection. */
@end
NS_ASSUME_NONNULL_END