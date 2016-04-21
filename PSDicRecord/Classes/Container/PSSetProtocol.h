//
//  PSSetProtocol.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/24.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSSetProtocol <NSObject, NSFastEnumeration>
- (NSUInteger)count;

- (nonnull NSSet<id> *)toSet;

- (void)addValue:(nonnull id)value;
- (void)addValuesFormSet:(nonnull NSSet<id> *)set;
- (void)addValuesFormArray:(nonnull NSArray<id> *)array;
- (void)removeValue:(nonnull id)value;
- (void)removeAllValues;

- (BOOL)contains:(nonnull id)value;

- (BOOL)isEqual:(nonnull id<PSSetProtocol>)object;
@end
