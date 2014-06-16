//
//  BWProduct.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 16/06/14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWProduct : NSObject<NSCoding>

@property NSNumber      *productId;
@property NSString      *name;
@property NSNumber      *price;
@property NSString      *updated;
@property NSDictionary  *info;

@end
