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
#import "BWPaymentViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <CommonCrypto/CommonDigest.h>

#define BEACON_WALLET_SERVICE_UUID           @"91514033-965D-45B0-8414-48E793DC6AEE"
#define BEACON_WALLET_CART_CHARACTERISTIC_UUID    @"18DBF890-DADD-454C-9161-7620EDFD3009"
#define BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID    @"A4D26C6B-3D39-49DD-9D7A-B38A20019D67"
#define BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID    @"FE9A5292-7CFF-45B6-812C-7B37F439FE3B"
#define BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID    @"DB0EB363-6D35-4C5D-92C7-E5F710899F7F"

@interface BWAppDelegate () <CBPeripheralManagerDelegate>
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *cartCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *invoiceCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *paymentCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *receiptCharacteristic;
@property (strong, nonatomic) NSArray                   *products;
@property (strong, nonatomic) BWIPhoneClient            *iPhoneAPI;

@end

@implementation BWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.iPhoneAPI = [BWIPhoneClient sharedClient];
    
    //check if we have products already
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString* docFile = [docDir stringByAppendingPathComponent: @"Products"];
    
    self.products = [NSKeyedUnarchiver unarchiveObjectWithFile:docFile];
    
//    if(!self.products) {
    if(true) {
        [self.iPhoneAPI getAllProducts:nil];
    }
    
    //Bluetooth stuff
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
//    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
//                                                           identifier:@"ch.beacon-wallet"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:23099 minor:1039 identifier:@"ch.beacon-wallet"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    //not useful for entering a branch
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
   
    
    self.accountTableViewController = [[BWAccountTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.scanViewController = [[BWScanViewController alloc] initWithNibName:nil bundle:nil];
    self.receiptTableViewController = [[BWReceiptTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *receiptNavigationController = [[UINavigationController alloc] initWithRootViewController:self.receiptTableViewController];
    
    self.window.tintColor = [UIColor colorWithRed:(245/255.0) green:(156/255.0) blue:0 alpha:1];
    
    self.tabBarViewController = [[BWTabBarViewController alloc] init];
    self.tabBarViewController.viewControllers = @[self.accountTableViewController, self.scanViewController, receiptNavigationController];
    
    self.window.rootViewController = self.tabBarViewController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if(false) {
        self.loginViewController = [[BWLoginViewViewController alloc] initWithNibName:@"BWLoginViewViewController" bundle:[NSBundle mainBundle]];
        [self.accountTableViewController presentViewController:self.loginViewController animated:NO completion:nil];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    
    BWWelcomeViewController *welcome = [[BWWelcomeViewController alloc] initWithNibName:@"BWWelcomeViewController" bundle:[NSBundle mainBundle]];
    
    [self.accountTableViewController presentViewController:welcome animated:YES completion:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"we entered coop");
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    
    notice.alertBody = @"Welcome to Coop Baden";
    notice.alertAction = @"Open";
    notice.soundName = UILocalNotificationDefaultSoundName;
    notice.userInfo = @{@"test": @"hallo"};
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
    
    //start ranging for cashierBeacon
    [self startRagingForCashierBeacon];
}

- (void) startRagingForCashierBeacon {
    NSUUID *cashierUUID = [[NSUUID alloc] initWithUUIDString:@"11111111-1111-1111-1111-111111111111"];
    self.cashierBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:cashierUUID
                                                           identifier:@"ch.beacon-wallet"];
    
    self.cashierBeaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startRangingBeaconsInRegion:self.cashierBeaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"raus!");
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    if ([beacons count] > 0) {
        //is this true??
        CLBeacon *nearestCashier = [beacons firstObject];
        
        [beacons enumerateObjectsUsingBlock:^(CLBeacon *beacon, NSUInteger idx, BOOL *stop) {
            //check if its a cashier
            if([beacon.minor isEqualToNumber:@1]) {
                NSString * const proximities[] = {
                    [CLProximityFar] = @"far",
                    [CLProximityImmediate] = @"immediate",
                    [CLProximityNear] = @"near",
                    [CLProximityUnknown] = @"unknown"
                };
                
                
                NSLog(@"did range cashier beacons %@", proximities[beacon.proximity]);
                //it has to be near to pay
                if(beacon.proximity == CLProximityImmediate) {
                    NSLog(@"start the payment process");
                    
                    [self startPaymentProcessWithAmount:@"123.40"];
                    
                    //stop ranging
                    [self.locationManager stopRangingBeaconsInRegion:self.cashierBeaconRegion];
                    
                    *stop = TRUE;
                }
            }
        }];
    }
}

- (void) locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%@", [error description]);
}

- (void) startPaymentProcessWithAmount:(NSString *)amount {
    BWPaymentViewController *paymentViewController = [[BWPaymentViewController alloc] initWithNibName:@"BWPaymentViewController" bundle:[NSBundle mainBundle]];
    paymentViewController.totalAmount.text = amount;
    
    [self.accountTableViewController presentViewController:paymentViewController animated:YES completion:nil];
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

#pragma mark CBPeripheralManagerDelegate methods
/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.cartCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BEACON_WALLET_CART_CHARACTERISTIC_UUID]
                                                                 properties:CBCharacteristicPropertyRead
                                                                      value:nil
                                                                permissions:CBAttributePermissionsReadable];
    
    self.invoiceCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID]
                                                                    properties:CBCharacteristicPropertyWrite
                                                                         value:nil
                                                                   permissions:CBAttributePermissionsWriteable];
    
    self.paymentCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]
                                                                    properties:(CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead)
                                                                         value:nil
                                                                   permissions:CBAttributePermissionsReadable];
    
    self.receiptCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID]
                                                                    properties:CBCharacteristicPropertyWrite
                                                                         value:nil
                                                                   permissions:CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BEACON_WALLET_SERVICE_UUID] primary:YES];
    
    // Add the characteristic to the service
    service.characteristics = @[self.cartCharacteristic, self.invoiceCharacteristic, self.paymentCharacteristic, self.receiptCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:service];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:BEACON_WALLET_SERVICE_UUID]] }];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_CART_CHARACTERISTIC_UUID]]) {
        NSLog(@"respond to cart read request");
        NSData* cart = [self getCart];
        
        if (request.offset > cart.length) {
            [self.peripheralManager respondToRequest:request
                                          withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        request.value = [cart subdataWithRange:NSMakeRange(request.offset, cart.length - request.offset)];
    } else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]]) {
        NSLog(@"respond to payment read request");
        NSData* payment = [self getPayment];
        
        if (request.offset > payment.length) {
            [self.peripheralManager respondToRequest:request
                                          withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        request.value = [payment subdataWithRange:NSMakeRange(request.offset, payment.length - request.offset)];
    }
    
    [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    
    CBATTRequest *request = [requests objectAtIndex:0];
    
    if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID]]) {
        
        NSString* invoice = [NSString stringWithUTF8String:[request.value bytes]];
        NSLog(@"invoice write request: %@", invoice);
        
        //display invoice screen
        [self startPaymentProcessWithAmount:invoice];
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
        //enter payment and send notification
        [self.peripheralManager updateValue:[self getPaymentNotification] forCharacteristic:self.paymentCharacteristic onSubscribedCentrals:nil];
    } else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID]]) {
        
        NSString* receipt = [NSString stringWithUTF8String:[request.value bytes]];
        NSLog(@"receipt write request: %@", receipt);
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

# pragma mark helper methods for data

- (NSData *)getCart {
    return [self encrypt:@"cart"];
}

- (NSData *)getPaymentNotification {
    return [@"payment notification" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getPayment {
    return [@"payment" dataUsingEncoding:NSUTF8StringEncoding];
}

# pragma mark security helper methods

- (NSData *)encrypt: (NSString *) plainText {
    
    // load certificate
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test_cert" ofType:@"der"];
    NSData* certificateData = [NSData dataWithContentsOfFile:filePath];
    
    SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData);
    
    SecPolicyRef secPolicy = SecPolicyCreateBasicX509();
    
    SecTrustRef trust;
    SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
    SecTrustResultType resultType;
    SecTrustEvaluate(trust, &resultType);
    SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
    
    // encrypt data
    NSData* plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    const size_t CIPHER_BUFFER_SIZE = 256;
    uint8_t cipherBuffer[CIPHER_BUFFER_SIZE];
    size_t cipherBufferSize = CIPHER_BUFFER_SIZE;
    
    OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, [plainTextData bytes], [plainTextData length], &cipherBuffer[0], &cipherBufferSize);
    NSData* encrypted = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    // clean up
    CFRelease(publicKey);
    CFRelease(trust);
    CFRelease(secPolicy);
    CFRelease(certificateFromFile);
    
    return encrypted;
}


@end
