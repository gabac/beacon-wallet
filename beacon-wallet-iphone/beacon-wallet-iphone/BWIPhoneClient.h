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

@interface BWIPhoneClient : AFHTTPSessionManager

+ (BWIPhoneClient *)sharedClient;

- (void)getAccountDetails:(void (^)(BWAccount *account, NSError *error))block;

@end
