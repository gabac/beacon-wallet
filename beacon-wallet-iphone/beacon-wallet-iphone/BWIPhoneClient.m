//
//  BWIPhoneClient.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 11.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWIPhoneClient.h"

static NSString * const kBWAPIBaseDebugURLString = @"http://beaconwallet.apiary-mock.com/";
static NSString * const kBWAPIBaseReleaseURLString = @"http://localhost:8000/";

#if DEBUG
    static NSString * const kEnv = @"development";
#else
    static NSString * const kEnv = @"production";
#endif

@implementation BWIPhoneClient

+ (BWIPhoneClient *)sharedClient {
    static BWIPhoneClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *url;
        
        //setting the url according to the environment
        if([kEnv isEqualToString:@"development"]) {
            url = kBWAPIBaseDebugURLString;
        } else {
            url = kBWAPIBaseReleaseURLString;
        }
        
        _sharedClient = [[BWIPhoneClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        
    });
    
    return _sharedClient;
}

- (void) getAccountDetails:(void (^)(BWAccount *account, NSError *error))block {
    [self GET:@"accounts/2501032235098" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        BWAccount *account = [[BWAccount alloc] init];
        
        account.card = [responseObject objectForKey: @"card"];
        
        if(block) {
            block(account, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(block) {
            block(nil, error);
        }
    }];
}

@end
