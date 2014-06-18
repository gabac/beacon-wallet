//
//  BWPaymentViewController.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 02.06.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWPaymentViewController.h"

@interface BWPaymentViewController ()

@end

@implementation BWPaymentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)pressedPay:(id)sender {
    
    [self.delegate didConfirmPayment];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self.totalAmountNumber intValue] <= 0) {
        self.totalAmountNumber = @"0.0";
    }
    self.totalAmount.text = self.totalAmountNumber;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
