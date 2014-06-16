//
//  BWReceiptDataItem.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWReceiptDataItem.h"

@implementation BWReceiptDataItem

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.barcode = [decoder decodeObjectForKey:@"barcode"];
    self.productId = [decoder decodeObjectForKey:@"productId"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.productId forKey:@"productId"];
}

@end
