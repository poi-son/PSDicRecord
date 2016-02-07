//
//  PSTable.h
//  PSExtensions
//
//  Created by PoiSon on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSModel.h"

@protocol PSSetProtocol;
@class PSTable;
@class PSColumn;

/**
 *  table structure
 */
@interface PSTable : PSModel<PSTable *>
+ (instancetype)buildTableWithModel:(Class)model;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) Class type;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *columns;
@property (nonatomic, assign) NSInteger version;


@property (nonatomic, readonly) NSArray<PSColumn *> *cols;

- (BOOL)hasColumn:(NSString *)column;
- (PSColumn *)columnForName:(NSString *)name;
@end
