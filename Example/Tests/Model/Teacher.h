//
//  Teacher.h
//  UnitCase
//
//  Created by PoiSon on 15/10/10.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <PSDicRecord/PSDicRecord.h>

@class Teacher;
@interface Teacher : PSModel<Teacher *>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int age;


@property (nonatomic, assign) NSInteger floors;
@end
