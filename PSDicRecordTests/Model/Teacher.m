//
//  Teacher.m
//  UnitCase
//
//  Created by PoiSon on 15/10/10.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "Teacher.h"
#import "Student.h"
#import <CoreData/CoreData.h>

@implementation Teacher
@dynamic name;
@dynamic age;

- (NSArray<Student *> *)getStudents{
    return nil;
//    return [[Student dao] find:@"select * from student where teacher_id = ?", [self valueForKey:@"id"]];
}

@end
