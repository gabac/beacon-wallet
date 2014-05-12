//
//  BWScanViewController.h
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"

@interface BWScanViewController : UIViewController<ScanditSDKOverlayControllerDelegate>

@property (strong, nonatomic) ScanditSDKBarcodePicker *scanditSDKBarcodePicker;

@end
