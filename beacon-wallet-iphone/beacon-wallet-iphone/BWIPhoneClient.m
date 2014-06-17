//
//  BWIPhoneClient.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 11.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWIPhoneClient.h"

static NSString * const kBWAPIBaseDebugURLString = @"http://localhost:8000/";
static NSString * const kBWAPIBaseApiaryURLString = @"http://beaconwallet.apiary-mock.com/";
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
            url = kBWAPIBaseApiaryURLString;
        } else {
            url = kBWAPIBaseReleaseURLString;
        }
        
        _sharedClient = [[BWIPhoneClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        
    });
    
    return _sharedClient;
}

- (void)getAccountDetails:(NSString *)cardnumber andPin:(NSString *)pin andBlock:(void (^)(BWAccount *account, NSError *error))block {
    [self GET:[NSString stringWithFormat:@"accounts/%@", cardnumber] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        BWAccount *account = [[BWAccount alloc] init];
        
        account.card = [responseObject objectForKey: @"card"];
        account.creditcard = [responseObject objectForKey: @"cc_nr"];
        account.pin = [responseObject objectForKey: @"pin"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex: 0];
        NSString* docFile = [docDir stringByAppendingPathComponent: @"Account"];
        
        [NSKeyedArchiver archiveRootObject:account toFile:docFile];
        
        if(block) {
            block(account, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(block) {
            block(nil, error);
        }
    }];
}

- (void) getAllProducts:(void (^)(NSError *error))block {
    [self GET:@"products" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex: 0];
        NSString* docFile = [docDir stringByAppendingPathComponent: @"Products"];
        
        self.products = [NSKeyedUnarchiver unarchiveObjectWithFile:docFile];
        
        if (!self.products) {
            self.products = [[NSMutableArray alloc] init];
        }
        
        [[responseObject objectForKey:@"products"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //id's of products
            
            [self getProductWithId:[obj objectForKey:@"id"] andBlock:^(BWProduct *product, NSError *error) {
                if (product) {
                    //add product to "db"
                    
                    [self.products enumerateObjectsUsingBlock:^(BWProduct *obj, NSUInteger idx, BOOL *stop) {
                        if([obj.productId isEqual:product.productId]) {
                            [self.products removeObject:obj];
                            *stop = YES;
                        }
                    }];
                    

                    [self.products addObject:product];
                    
                    [NSKeyedArchiver archiveRootObject:self.products toFile:docFile];
                }
            }];
        }];
        
        if(block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(block) {
            block(error);
        }
    }];
}

- (void) getProductWithId:(NSNumber *)productId andBlock:(void (^)(BWProduct *product, NSError *error))block {
    [self GET:[NSString stringWithFormat:@"products/%@", productId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"productid %@", [responseObject objectForKey:@"id"]);
        
        BWProduct *product = [[BWProduct alloc] init];
        product.productId = [responseObject objectForKey:@"id"];
        product.name = [responseObject objectForKey:@"name"];
        product.price = [responseObject objectForKey:@"price"];
        product.info = [responseObject objectForKey:@"info"];
        product.barcodes = [responseObject objectForKey:@"barcodes"];
        
        
        if(block) {
            block(product, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(block) {
            block(nil, error);
        }
    }];
}

@end
