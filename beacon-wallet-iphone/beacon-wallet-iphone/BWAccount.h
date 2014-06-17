//
//  BWAccount.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWAccount : NSObject<NSCoding>

@property (strong, nonatomic) NSString *card;
@property (strong, nonatomic) NSString *creditcard;
@property (strong, nonatomic) NSString *pin;

@end
