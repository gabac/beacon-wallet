//
//  BWAccount.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWAccount.h"

@implementation BWAccount

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.card = [decoder decodeObjectForKey:@"card"];
    self.creditcard = [decoder decodeObjectForKey:@"creditcard"];
    self.pin = [decoder decodeObjectForKey:@"pin"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.card forKey:@"card"];
    [encoder encodeObject:self.creditcard forKey:@"creditcard"];
    [encoder encodeObject:self.pin forKey:@"pin"];
}

@end
