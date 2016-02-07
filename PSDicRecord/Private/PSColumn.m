//
//  PSColumn.m
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "PSDicRecord_private.h"

@implementation PSColumn{
    __weak id<PSTypeConvertor> _convertor;
}

- (instancetype)initWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes{
    if (self = [super init]) {
        _name = attributes[@"name"];
        _type = attributes[@"type"];
    }
    return self;
}

- (BOOL)isEqual:(PSColumn *)object{
    returnValIf(![object isKindOfClass:self.class], NO);
    return [object.name isEqualToString:self.name] && [object.type isEqualToString:self.type];
}

- (NSUInteger)hash{
    return self.type.hash + self.name.hash;
}

- (id<PSTypeConvertor>)convertor{
    return _convertor ?: (_convertor = [PSDbKit convertorForType:self.type]);
}

- (NSDictionary<NSString *,NSString *> *)attributes{
    NSMutableDictionary<NSString *, NSString *> *attributes = [NSMutableDictionary dictionary];
    attributes[@"name"] = self.name;
    attributes[@"type"] = self.type;
    return attributes;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<PSColumn %p> { name : %@, type : %@}", self, self.name, self.type];
}

- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"<PSColumn %p>\n{\n   name : %@,\n   type : %@\n}", self, self.name, self.type];
}
@end
