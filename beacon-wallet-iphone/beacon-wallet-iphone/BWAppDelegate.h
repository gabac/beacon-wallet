//
//  BWAppDelegate.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 24.03.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWAccountViewController.h"
#import "BWTabBarViewController.h"

@interface BWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BWAccountViewController *accountViewController;
@property (strong, nonatomic) BWTabBarViewController  *tabBarViewController;

@end
