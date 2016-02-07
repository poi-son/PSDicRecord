//
//  PSSQLBuilder.h
//  PSExtensions
//
//  Created by PoiSon on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSTable;
@class PSColumn;
@class PSSql;
@protocol PSSetProtocol;
@protocol PSDictionaryProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PSSqlBuilder : NSObject
+ (PSSql *)forCreate:(PSTable *)table;
+ (PSSql *)forAddColumn:(PSColumn *)column toTable:(PSTable *)table;
+ (PSSql *)forRowCount:(PSTable *)table byCondition:(NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (PSSql *)forSave:(PSTable *)table attrs:(id<PSDictionaryProtocol>)attrs;
+ (PSSql *)forUpdate:(PSTable *)table attrs:(id<PSDictionaryProtocol>)attrs modifyFlag:(NSSet<NSString *> *)modifyFlags;
+ (PSSql *)forReplace:(PSTable *)table attrs:(id<PSDictionaryProtocol>)attrs;
+ (PSSql *)forDelete:(PSTable *)table byCondition:(nullable NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (PSSql *)forFind:(PSTable *)table columns:(nullable NSString *)columns byCondition:(nullable NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (PSSql *)forPaginateIndex:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(nullable NSString *)where args:(nullable NSArray<id> *)args;
@end

NS_ASSUME_NONNULL_END