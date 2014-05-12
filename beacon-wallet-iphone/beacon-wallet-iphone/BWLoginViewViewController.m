//
//  BWLoginViewViewController.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWLoginViewViewController.h"

@interface BWLoginViewViewController ()
@property (weak, nonatomic) IBOutlet UITextField *supercardNumber;
@property (weak, nonatomic) IBOutlet UITextField *password;

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
