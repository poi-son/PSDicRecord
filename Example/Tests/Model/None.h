//
//  None.h
//  PSDicRecord
//
//  Created by PoiSon on 16/3/3.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import <PSDicRecord/PSDicRecord.h>

@class None;

@interface None : PSModel<None *>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int age;
@end
