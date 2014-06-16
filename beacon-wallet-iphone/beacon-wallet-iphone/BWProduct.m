//
//  BWProduct.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 16/06/14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWProduct.h"

@implementation BWProduct

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.productId = [decoder decodeObjectForKey:@"productId"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.price = [decoder decodeObjectForKey:@"price"];
    self.updated = [decoder decodeObjectForKey:@"updated"];
    self.info = [decoder decodeObjectForKey:@"info"];
    self.barcodes = [decoder decodeObjectForKey:@"barcodes"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.productId forKey:@"productId"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.price forKey:@"price"];
    [encoder encodeObject:self.updated forKey:@"updated"];
    [encoder encodeObject:self.barcodes forKey:@"barcodes"];
}

@end
