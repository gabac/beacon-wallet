//
//  BWLoginViewViewController.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWLoginViewViewController.h"
#import "BWIPhoneClient.h"

@interface BWLoginViewViewController ()

@end

@implementation BWLoginViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)pressedLoginButton:(id)sender {
    [self.password resignFirstResponder];
    
    BWIPhoneClient *iPhoneAPI = [BWIPhoneClient sharedClient];
    
    [iPhoneAPI getAccountDetails:self.cardnumber.text andPin:self.password.text andBlock:^(BWAccount *account, NSError *error) {
        self.accountTableViewController.account = account;
        [self.accountTableViewController.tableView reloadData];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate didLogin];
        }];
    }];
}
- (IBAction)didEndOnExit:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
