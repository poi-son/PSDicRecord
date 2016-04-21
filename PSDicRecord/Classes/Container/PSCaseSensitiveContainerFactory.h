//
//  PSCaseSensitiveContainerFactory.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/24.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSDicRecord/PSContainerFactory.h>
#import <PSDicRecord/PSDictionaryProtocol.h>
#import <PSDicRecord/PSSetProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@class PSCaseSensitiveSet<ValueType: NSString *>;
@class PSCaseSensitiveDictionary;

@interface PSCaseSensitiveContainerFactory : NSObject<PSContainerFactory>
- (PSCaseSensitiveSet<NSString *> *)createSet;

- (PSCaseSensitiveDictionary *)createDictionary;
@end

@interface PSCaseSensitiveDictionary<ValueType> : NSObject<PSDictionaryProtocol>
- (NSArray<NSString *> *)allKeys;
- (NSDictionary<NSString *,id> *)toDictionary;

- (void)setValue:(nullable ValueType)value forKey:(NSString *)aKey;
- (void)setDictionary:(NSDictionary<NSString *, ValueType> *)aDictionary;
- (void)removeValueForKey:(NSString *)aKey;
- (nullable ValueType)valueForKey:(NSString *)aKey;
@end

@interface PSCaseSensitiveSet<ValueType : NSString *> : NSObject<PSSetProtocol>
- (NSSet<ValueType> *)toSet;

- (void)addValue:(ValueType)value;
- (void)addValuesFormSet:(NSSet<ValueType> *)set;
- (void)addValuesFormArray:(NSArray<ValueType> *)array;
- (void)removeValue:(ValueType)value;

- (BOOL)contains:(ValueType)value;
@end
NS_ASSUME_NONNULL_END