//
//  BWReceiptDataItem.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWProduct.h"

@interface BWReceiptDataItem : NSObject<NSCoding>

@property NSString *barcode;
@property NSNumber *qty;
@property BWProduct *product;

@end
