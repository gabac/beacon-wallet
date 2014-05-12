//
//  BWScanViewController.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWScanViewController.h"

@interface BWScanViewController ()

@property (strong, nonatomic) ScanditSDKBarcodePicker *scanditSDKBarcodePicker;
@property NSMutableArray *receiptDataItems;

@end

@implementation BWScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Scan";
        self.tabBarItem.image = [UIImage imageNamed:@"ScanIcon"];
        
        // Prepare the picker such that it can be loaded faster
        [ScanditSDKBarcodePicker prepareWithAppKey:@"1eHrynHTEeGVqLMegY9OCNXiWpxx0xHhmR4zth7UBoU"
                            cameraFacingPreference:CAMERA_FACING_BACK];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.receiptDataItems = [[NSMutableArray alloc] init];
    
    self.scanditSDKBarcodePicker = [[ScanditSDKBarcodePicker alloc]
									initWithAppKey:@"1eHrynHTEeGVqLMegY9OCNXiWpxx0xHhmR4zth7UBoU"];
    
    self.scanditSDKBarcodePicker.overlayController.delegate = self;
    
    [self.view addSubview:self.scanditSDKBarcodePicker.view];
    
	[self.scanditSDKBarcodePicker startScanning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scandit Delegate methods

- (void)scanditSDKOverlayController: (ScanditSDKOverlayController *)scanditSDKOverlayController
                     didScanBarcode:(NSDictionary *)barcodeResult {
    // add your own code to handle the barcode result e.g.
    NSString *symbology = [barcodeResult objectForKey:@"symbology"];
    NSString *barcode = [barcodeResult objectForKey:@"barcode"];
    NSLog(@"scanned %@ barcode: %@", symbology, barcode);
    
    BWReceiptDataItem *dataItem = [[BWReceiptDataItem alloc] init];
    dataItem.barcode = barcode;
    [self.receiptDataItems addObject:dataItem];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString* docFile = [docDir stringByAppendingPathComponent: @"Storage"];
    
    NSMutableArray *storedReceiptDataItems = [NSKeyedUnarchiver unarchiveObjectWithFile:docFile];
    
    if(storedReceiptDataItems) {
        [self.receiptDataItems addObjectsFromArray:storedReceiptDataItems];
    }
    
    [NSKeyedArchiver archiveRootObject:self.receiptDataItems toFile:docFile];
}

- (void)scanditSDKOverlayController: (ScanditSDKOverlayController *)scanditSDKOverlayController
                didCancelWithStatus:(NSDictionary *)status {
    // add your own code to handle the user canceling the barcode scan process
}

- (void)scanditSDKOverlayController: (ScanditSDKOverlayController *)scanditSDKOverlayController
                    didManualSearch:(NSString *)input {
    // add your own code to handle user input in the search bar
    // (only required if you use the search bar provided by the Scandit SDK
}

@end
