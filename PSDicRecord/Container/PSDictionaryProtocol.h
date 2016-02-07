//
//  PSDictionaryProtocol.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/24.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSDictionaryProtocol <NSObject, NSFastEnumeration>
- (nonnull NSArray<NSString *> *)allKeys;
- (nonnull NSDictionary<NSString *, id> *)toDictionary;

- (void)setValue:(nullable id)value forKey:(nonnull NSString *)aKey;
- (void)setDictionary:(nonnull NSDictionary<NSString *, id> *)aDictionary;
- (void)removeValueForKey:(nonnull NSString *)aKey;
- (void)removeAllValues;
- (nullable id)valueForKey:(nonnull NSString *)aKey;

- (BOOL)isEqual:(nonnull id<PSDictionaryProtocol>)object;
@end