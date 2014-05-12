//
//  BWAppDelegate.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 24.03.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWAccountTableViewController.h"
#import "BWTabBarViewController.h"
#import "BWScanViewController.h"
#import "BWReceiptTableViewController.h"
#import "BWLoginViewViewController.h"

@interface BWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BWAccountTableViewController   *accountTableViewController;
@property (strong, nonatomic) BWTabBarViewController    *tabBarViewController;
@property (strong, nonatomic) BWScanViewController      *scanViewController;
@property (strong, nonatomic) BWReceiptTableViewController   *receiptTableViewController;
@property  BWLoginViewViewController *loginViewController;

@end
