//
//  BWWelcomeViewController.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 02.06.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWWelcomeViewController.h"

@interface BWWelcomeViewController ()

@end

@implementation BWWelcomeViewController

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
- (IBAction)pressedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
