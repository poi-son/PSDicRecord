//
//  PSContainerFactory.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/24.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSSetProtocol;
@protocol PSDictionaryProtocol;

@protocol PSContainerFactory <NSObject>
- (nonnull id<PSSetProtocol>)createSet;
- (nonnull id<PSDictionaryProtocol>)createDictionary;
@end
