//
//  BWPaymentViewController.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 02.06.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BWPaymentViewControllerDelegate;

@interface BWPaymentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *totalAmount;
@property (assign) NSObject <BWPaymentViewControllerDelegate> *delegate;
@property NSString *totalAmountNumber

@end

@protocol BWPaymentViewControllerDelegate <NSObject>

- (void)didConfirmPayment;

@end
