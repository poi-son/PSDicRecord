//
//  PSRecord.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/10.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSDicRecord/PSDbAttribute.h>

NS_ASSUME_NONNULL_BEGIN
@interface PSRecord : PSDbAttribute
+ (instancetype)recordWithAttributes:(NSDictionary<NSString *, id> *)attributes;

- (void)setRecord:(PSRecord *)aRecord;/**< Copy attribute from ${aRecord} to record. */
@end
NS_ASSUME_NONNULL_END