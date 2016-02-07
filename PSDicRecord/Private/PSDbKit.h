//
//  PSDbKit.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/1.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSDbConfig;
@class PSTable;
@protocol PSTypeConvertor;

NS_ASSUME_NONNULL_BEGIN
@interface PSDbKit : NSObject

+ (PSDbConfig *)brokenConfig;
+ (PSDbConfig *)mainConfig;

#pragma mark -
+ (void)addConfig:(PSDbConfig *)config;
+ (void)addModel:(Class)model toConfigMapping:(PSDbConfig *)config;
+ (void)addModel:(Class)model toTableMapping:(PSTable *)table;

+ (PSDbConfig *)configForName:(NSString *)configName;
+ (PSDbConfig *)configForModel:(Class)model;
+ (PSTable *)tableForModel:(Class)model;
+ (PSTable *)tableForName:(NSString *)tableName;

#pragma mark -
+ (id<PSTypeConvertor>)convertorForType:(NSString *)typeEncoding;
+ (id<PSTypeConvertor>)convertorForObject:(id)obj;
+ (void)addConvertor:(id<PSTypeConvertor>)convertor;
@end
NS_ASSUME_NONNULL_END