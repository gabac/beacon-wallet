//
//  BWAppDelegate.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 24.03.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWAppDelegate.h"
#import "BWIPhoneClient.h"
#import "BWWelcomeViewController.h"

@implementation BWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
//    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
//                                                           identifier:@"ch.beacon-wallet"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:23099 minor:1039 identifier:@"ch.beacon-wallet"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
   
    
    self.accountTableViewController = [[BWAccountTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.scanViewController = [[BWScanViewController alloc] initWithNibName:nil bundle:nil];
    self.receiptTableViewController = [[BWReceiptTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:(245/255.0) green:(156/255.0) blue:0 alpha:1]];
    
    self.tabBarViewController = [[BWTabBarViewController alloc] init];
    self.tabBarViewController.viewControllers = @[self.accountTableViewController, self.scanViewController, self.receiptTableViewController];
    
    self.window.rootViewController = self.tabBarViewController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if(true) {
        self.loginViewController = [[BWLoginViewViewController alloc] initWithNibName:@"BWLoginViewViewController" bundle:[NSBundle mainBundle]];
        [self.accountTableViewController presentViewController:self.loginViewController animated:NO completion:nil];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    if(self.accountTableViewController.view.superview == nil) {
        BWWelcomeViewController *welcome = [[BWWelcomeViewController alloc] initWithNibName:@"BWWelcomeViewController" bundle:[NSBundle mainBundle]];
        
        [self.accountTableViewController presentViewController:welcome animated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"something happened");
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    
    notice.alertBody = @"Welcome to Coop Baden";
    notice.alertAction = @"Open";
    notice.userInfo = @{@"test": @"hallo"};
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    if ([beacons count] > 0) {
        CLBeacon *nearestExhibit = [beacons firstObject];
        NSString * const proximities[] = {
            [CLProximityFar] = @"far",
            [CLProximityImmediate] = @"immediate",
            [CLProximityNear] = @"near",
            [CLProximityUnknown] = @"unknown"
        };
        // Present the exhibit-specific UI only when
        // the user is relatively close to the exhibit.
//        if (CLProximityNear == nearestExhibit.proximity) {
//            NSLog(@"%ld", (long)nearestExhibit.major.integerValue);
//        } else {
//            NSLog(@"not there any more %@", proximities[nearestExhibit.proximity]);
//        }
//        NSLog(@"did range beacons %@", proximities[nearestExhibit.proximity]);
        
        [beacons enumerateObjectsUsingBlock:^(CLBeacon *beacon, NSUInteger idx, BOOL *stop) {
            if ([beacon.major isEqualToNumber:@23099]) {
//                NSLog(@"coop baden");
                
            }
            if([beacon.minor isEqualToNumber:@1039]) {
//                NSLog(@"Welcome to the coop");
            }
//            NSLog(@"%@", beacon.minor);
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
