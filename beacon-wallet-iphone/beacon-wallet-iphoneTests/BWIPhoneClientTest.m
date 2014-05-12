//
//  BWIPhoneClientTest.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 11.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BWIPhoneClient.h"
#import "OCMock.h"

@interface BWIPhoneClientTest : XCTestCase

@property (strong, nonatomic) BWIPhoneClient *apiClient;

@end

@implementation BWIPhoneClientTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.apiClient = [BWIPhoneClient sharedClient];
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    
    // create a mock of the AFHTTPClient:
    id mockClient = [OCMockObject mockForClass:[BWIPhoneClient class]];
    
    // 1) build the expectations
    //  * we expect that the "getPath" is invoked, once!
    //  * here we don't care too much about the passed in arguments...
    //  * we use the andDo function to invoke the GIVEN (notNil) success block with our mocked JSON
    [[[mockClient expect] andDo:^(NSInvocation *invocation) {
        // we define the sucess block:
        void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = nil;
        
        // Using NSInvocation, we get access to the concrete block function
        // that has been passed in by the actual test
        // the arguments for the actual method start with 2 (see NSInvocation doc)
        [invocation getArgument:&successBlock atIndex:4];
        
        // now we invoke the successBlock with some "JSON"...:
        successBlock(nil,
                     [NSDictionary dictionaryWithObjectsAndKeys:@"Bom Dia", @"greetings", nil]
                     );
        
    }] POST:[OCMArg isNotNil] parameters:[OCMArg isNil] success:[OCMArg isNotNil] failure:[OCMArg isNotNil]];
    
    // 2) run the actual test:
    [mockClient POST:@"/account" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertEqualObjects(@"Bom Dia", [responseObject objectForKey:@"greetings"], @"fake JSON");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL");
    }];
}

@end
