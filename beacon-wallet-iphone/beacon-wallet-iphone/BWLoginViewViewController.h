//
//  BWLoginViewViewController.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWAccountTableViewController.h"

@interface BWLoginViewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *cardnumber;
@property BWAccountTableViewController *accountTableViewController;

@end
