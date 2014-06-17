//
//  BWIPhoneClient.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 11.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "BWAccount.h"
#import "BWProduct.h"

@interface BWIPhoneClient : AFHTTPSessionManager

@property NSMutableArray *products;

+ (BWIPhoneClient *)sharedClient;

- (void)getAccountDetails:(NSString *)cardnumber andPin:(NSString *)pin andBlock:(void (^)(BWAccount *account, NSError *error))block;
- (void) getAllProducts:(void (^)(NSError *error))block;
- (void) getProductWithId:(NSNumber *)productId andBlock:(void (^)(BWProduct *product, NSError *error))block;

@end
