//
//  PSColumn.h
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSModel.h"

@class PSColumn;
@protocol PSTypeConvertor;
/**
 *  column structure
 */
@interface PSColumn : NSObject
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak, readonly) id<PSTypeConvertor> convertor;

@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *attributes;
@end
