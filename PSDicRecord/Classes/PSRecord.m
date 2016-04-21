//
//  PSRecord.m
//  PSExtensions
//
//  Created by PoiSon on 15/10/10.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"

@implementation PSRecord
- (id)copyWithZone:(NSZone *)zone{
    PSRecord *new = [[self.class allocWithZone:zone] initWithAttributes:self.attributes];
    return new;
}

+ (instancetype)recordWithAttributes:(NSDictionary<NSString *,id> *)attributes{
    return [[self alloc] initWithAttributes:attributes];
}

- (void)setRecord:(PSRecord *)record{
    [self setDictionary:record.attributes];
}

@end
