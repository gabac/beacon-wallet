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
#import "BWReceiptViewController.h"
#import "BWUpdateAppViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <CommonCrypto/CommonDigest.h>

#define BEACON_WALLET_SERVICE_UUID           @"91514033-965D-45B0-8414-48E793DC6AEE"
#define BEACON_WALLET_CART_CHARACTERISTIC_UUID    @"18DBF890-DADD-454C-9161-7620EDFD3009"
#define BEACON_WALLET_CART_NOTIFY_CHARACTERISTIC_UUID    @"F810FE46-3E85-4693-AE48-0B562FEC9AEC"
#define BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID    @"A4D26C6B-3D39-49DD-9D7A-B38A20019D67"
#define BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID    @"FE9A5292-7CFF-45B6-812C-7B37F439FE3B"
#define BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID    @"DB0EB363-6D35-4C5D-92C7-E5F710899F7F"

#define NOTIFY_MTU      20

typedef enum
{
    PaymentProcessAcceptConnections,
    PaymentProcessInvoice,
    PaymentProcessPayment,
    PaymentProcessReceipt
}
PaymentProcess;

@interface BWAppDelegate () <CBPeripheralManagerDelegate>
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *cartCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *cartNotifyCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *invoiceCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *paymentCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *receiptCharacteristic;
@property (strong, nonatomic) NSArray                   *products;
@property (strong, nonatomic) BWIPhoneClient            *iPhoneAPI;
@property BWPaymentViewController                       *paymentViewController;
@property NSString                                      *totalAmount;
@property NSInteger                                     sendDataIndex;
@property NSData                                        *dataToSend;
@property CBMutableCharacteristic                       *characteristicToSendTo;
@property (strong, nonatomic) NSMutableData             *invoice;
@property BWAccount                                     *account;
@property NSString                                      *transactionId;
@end

@implementation BWAppDelegate

PaymentProcess paymentProcess;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.iPhoneAPI = [BWIPhoneClient sharedClient];
    paymentProcess = PaymentProcessAcceptConnections;
    
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
    
    //check if the user has already an account
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString* docFileAccount = [docDir stringByAppendingPathComponent: @"Account"];
    
    BWAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:docFileAccount];
    
    if(!account) {
        self.loginViewController = [[BWLoginViewViewController alloc] initWithNibName:@"BWLoginViewViewController" bundle:[NSBundle mainBundle]];
        self.loginViewController.accountTableViewController = self.accountTableViewController;
        self.loginViewController.delegate = self;
        
        [self.accountTableViewController presentViewController:self.loginViewController animated:NO completion:nil];
    } else {
        self.account = account;
        
        self.accountTableViewController.account = account;
        [self.accountTableViewController.tableView reloadData];
    }
    
    self.invoice = [[NSMutableData alloc] init];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    
    BWWelcomeViewController *welcome = [[BWWelcomeViewController alloc] initWithNibName:@"BWWelcomeViewController" bundle:[NSBundle mainBundle]];
    
    [self.accountTableViewController presentViewController:welcome animated:YES completion:nil];
    
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

#pragma mark CoreLocation

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
                                                                 properties:(CBCharacteristicPropertyRead)
                                                                      value:nil
                                                                permissions:CBAttributePermissionsReadable];
    self.cartNotifyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BEACON_WALLET_CART_NOTIFY_CHARACTERISTIC_UUID]
                                                                 properties:(CBCharacteristicPropertyNotify)
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
    service.characteristics = @[self.cartCharacteristic, self.cartNotifyCharacteristic, self.invoiceCharacteristic, self.paymentCharacteristic, self.receiptCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:service];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:BEACON_WALLET_SERVICE_UUID]] }];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_CART_CHARACTERISTIC_UUID]] && paymentProcess == PaymentProcessAcceptConnections) {
        NSLog(@"respond to cart read request");
        
        paymentProcess = PaymentProcessInvoice;
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        // Get the data
        self.dataToSend = [self getCart];
        
        // Reset the index
        self.sendDataIndex = 0;
        
        //set the characteristic
        self.characteristicToSendTo = self.cartNotifyCharacteristic;
        
        // Start sending
        [self sendData];
        
        // reset invoice
        [self.invoice setLength:0];
        
    } else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]] && paymentProcess == PaymentProcessPayment) {
        
        NSLog(@"respond to payment read request");
        paymentProcess = PaymentProcessReceipt;
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
        // Get the data
        self.dataToSend = [self getPayment];
        
        // Reset the index
        self.sendDataIndex = 0;
        
        //set the characteristic
        self.characteristicToSendTo = self.paymentCharacteristic;
        
        // Start sending
        [self sendData];

    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    
    CBATTRequest *request = [requests objectAtIndex:0];
    
    NSLog(@"write request: %@ %@", request.characteristic.UUID, [NSString stringWithUTF8String:[request.value bytes]]);
    
    if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID]] && paymentProcess == PaymentProcessInvoice) {

        NSData* data = request.value;
        NSString* message = [NSString stringWithUTF8String:[data bytes]];
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
        // finished with invoice write?
        if ([message isEqualToString:@"EOM"]) {
            
            paymentProcess = PaymentProcessPayment;
            
            NSDictionary *invoice = [NSJSONSerialization JSONObjectWithData:self.invoice options:0 error:nil];
            NSString *transactionString =[invoice valueForKey:@"transaction"];
            NSDictionary *transaction = [NSJSONSerialization JSONObjectWithData:[transactionString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            
            self.transactionId = [transaction valueForKey:@"id"];
            
            NSLog(@"Received invoice %@", transaction);
            
            //display invoice screen
            [self startPaymentProcessWithAmount: [transaction valueForKey:@"amount"]];
            
            return;
        }
        
        // else append if
        [self.invoice appendData:data];
        
    } else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID]] && paymentProcess == PaymentProcessReceipt) {
        
        paymentProcess = PaymentProcessAcceptConnections;
        
        NSString* receipt = [NSString stringWithUTF8String:[request.value bytes]];
        NSLog(@"receipt write request: %@", receipt);
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
        [self showReceiptView];
    }
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}

# pragma mark helper methods for data & sending data

- (NSData *)getCart {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString* docFile = [docDir stringByAppendingPathComponent: @"Storage"];
    
    NSArray *receiptDataItems = [NSKeyedUnarchiver unarchiveObjectWithFile:docFile];
    
    if(!self.account) {
        NSString* docFileAccount = [docDir stringByAppendingPathComponent: @"Account"];
        self.account = [NSKeyedUnarchiver unarchiveObjectWithFile:docFileAccount];
    }
    
    NSMutableDictionary *cart = [[NSMutableDictionary alloc] init];
    //todo get number
    [cart setObject:self.account.card forKey:@"card"];
    
    NSMutableArray *productsWithQty = [[NSMutableArray alloc] init];
    
    [receiptDataItems enumerateObjectsUsingBlock:^(BWReceiptDataItem *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *productDict = [[NSMutableDictionary alloc] init];
        
        if (obj.product) {
            [productDict setObject:obj.product.productId forKey:@"id"];
        } else {
            [productDict setObject:@"1" forKey:@"id"];
        }
        
        [productDict setObject:obj.qty forKey:@"quantity"];
        
        [productsWithQty addObject:productDict];
    }];
    
    [cart setObject:productsWithQty forKey:@"products"];
    
    NSLog(@"json %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:cart options:0 error:nil] encoding:NSUTF8StringEncoding]);
    
    return [self encrypt:[NSJSONSerialization dataWithJSONObject:cart options:0 error:nil]];
}

- (NSData *)getPaymentNotification {
    return [@"payment notification" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getPayment {
    
    NSMutableDictionary *payment = [[NSMutableDictionary alloc] init];
    //todo
    //where to get transactionid?
    [payment setObject:self.transactionId forKey:@"id"]; // transaction id
    [payment setObject:self.account.card forKey:@"card"];
    [payment setObject:self.account.pin forKey:@"pin"];
    [payment setObject:self.totalAmount forKey:@"amount"];
    
    NSLog(@"json %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:payment options:0 error:nil] encoding:NSUTF8StringEncoding]);
    
    return [self encrypt:[NSJSONSerialization dataWithJSONObject:payment options:0 error:nil]];
}

- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristicToSendTo onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.characteristicToSendTo onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSLog(@"Sent: %@", chunk);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristicToSendTo onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

# pragma mark security helper methods

- (NSData *)encrypt: (NSData *) plainTextData {
    
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

#pragma mark PaymentviewController delegate methods 

- (void)didConfirmPayment {
    //enter payment and send notification
    NSLog(@"payment notification");
    
    [self.peripheralManager updateValue:[self getPaymentNotification] forCharacteristic:self.paymentCharacteristic onSubscribedCentrals:nil];
}

#pragma mark LoginViewController delegate methods

- (void)didLogin {
    //get product data
    BWUpdateAppViewController *updateAppViewController = [[BWUpdateAppViewController alloc] initWithNibName:@"BWUpdateAppViewController" bundle:[NSBundle mainBundle]];
    
   [self.accountTableViewController presentViewController:updateAppViewController animated:YES completion:nil];
}

#pragma mark Helper methods for views

- (void) startPaymentProcessWithAmount:(NSString *)amount {
    //we need it later
    self.totalAmount = amount;
    
    self.paymentViewController = [[BWPaymentViewController alloc] initWithNibName:@"BWPaymentViewController" bundle:[NSBundle mainBundle]];
    self.paymentViewController.totalAmountNumber = amount;
    self.paymentViewController.delegate = self;
    
    [self.tabBarViewController presentViewController:self.paymentViewController animated:YES completion:nil];
}

- (void) showReceiptView {
    BWReceiptViewController *receiptViewController = [[BWReceiptViewController alloc] initWithNibName:@"BWReceiptViewController" bundle:[NSBundle mainBundle]];
    
    [self.tabBarViewController presentViewController:receiptViewController animated:YES completion:nil];
    
}


@end
