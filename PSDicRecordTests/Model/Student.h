//
//  Student.h
//  UnitCase
//
//  Created by PoiSon on 15/10/8.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <PSDicRecord/PSDicRecord.h>

@class Student;

@interface Student : PSModel<Student *>
@property (nonatomic, retain) NSString *name;/**< 姓名 */
@property (nonatomic, assign) int age;/**< 年龄 */
@property (nonatomic, retain) NSDate *date;
@end
