//
//  ViewController.m
//  beacon-wallet-pos
//
//  Created by Fabian on 05.06.14.
//
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define BEACON_WALLET_SERVICE_UUID           @"91514033-965D-45B0-8414-48E793DC6AEE"
#define BEACON_WALLET_CART_CHARACTERISTIC_UUID    @"18DBF890-DADD-454C-9161-7620EDFD3009"
#define BEACON_WALLET_CART_NOTIFY_CHARACTERISTIC_UUID    @"F810FE46-3E85-4693-AE48-0B562FEC9AEC"
#define BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID    @"A4D26C6B-3D39-49DD-9D7A-B38A20019D67"
#define BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID    @"FE9A5292-7CFF-45B6-812C-7B37F439FE3B"
#define BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID    @"DB0EB363-6D35-4C5D-92C7-E5F710899F7F"

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) IBOutlet UIProgressView *progress;

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *cart;
@property (strong, nonatomic) NSMutableData         *payment;
@property (strong, nonatomic) CBCharacteristic      *invoiceCharacteristic;
@property (strong, nonatomic) CBCharacteristic      *paymentCharacteristic;
@property (strong, nonatomic) CBCharacteristic      *receiptCharacteristic;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.cart = [[NSMutableData alloc] init];
    self.payment = [[NSMutableData alloc] init];
}

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
    
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:BEACON_WALLET_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the BEACON_WALLET_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    int distance = 35; // (Close is around -22dB)

    float progress = 1 + ((RSSI.floatValue + distance) / 60);
    
    NSLog(@"Discovered %@ at %@, %f", peripheral.name, RSSI, progress);
    
    self.progress.progress = progress;
    
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough
    if (RSSI.integerValue < -distance) {
        return;
    }

    self.view.backgroundColor = [UIColor colorWithRed:(76/255.0) green:(217/255.0) blue:(100/255.0) alpha:1.0];
    
    // Ok, it's in range - have we already seen it?
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.cart setLength:0];
    [self.payment setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:BEACON_WALLET_SERVICE_UUID]]];
}


/** The Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BEACON_WALLET_CART_CHARACTERISTIC_UUID], [CBUUID UUIDWithString:BEACON_WALLET_CART_NOTIFY_CHARACTERISTIC_UUID], [CBUUID UUIDWithString:BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID], [CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID], [CBUUID UUIDWithString:BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID]] forService:service];
    }
}


/** The characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_CART_CHARACTERISTIC_UUID]]) {
            
            // If it is, read it
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_CART_NOTIFY_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID]]) {
            self.invoiceCharacteristic = characteristic;
        } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.paymentCharacteristic = characteristic;
        } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID]]) {
            self.receiptCharacteristic = characteristic;
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
    }
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_CART_NOTIFY_CHARACTERISTIC_UUID]]) {
        
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@" cart: %@", stringFromData);
        // Have we got everything we need?
        if ([stringFromData isEqualToString:@"EOM"]) {
            
            // Log it
            NSLog(@"Received cart: %@", self.cart);
            
            NSString* cartBase64 = [self.cart base64EncodedStringWithOptions:0];
            
            // send to server
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"cart": cartBase64};
            [manager POST:@"http://beaconwallet.apiary-mock.com/transactions" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                
                //send invoice
                [self.discoveredPeripheral writeValue:operation.responseData
                                    forCharacteristic:self.invoiceCharacteristic
                                                 type:CBCharacteristicWriteWithResponse];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            // Cancel our subscription to the characteristic
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        }
        
        // Otherwise, just add the data on to what we already have
        [self.cart appendData:characteristic.value];

    } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]]) {
        
        NSString *payment = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        // Log it
        // this method gets called for notify and the read request, filter it somehow
        if([payment isEqual:@"payment notification"]) {
            NSLog(@"Received payment notification");
            [self.discoveredPeripheral readValueForCharacteristic:self.paymentCharacteristic];
        } else {
            //do the payment
            NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            NSLog(@" payment: %@", stringFromData);
            // Have we got everything we need?
            if ([stringFromData isEqualToString:@"EOM"]) {
                
                // Log it
                NSLog(@"Received payment: %@", self.payment);
                
                NSString* paymentBase64 = [self.payment base64EncodedStringWithOptions:0];
                
                // send to server
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *parameters = @{@"payment": paymentBase64};
                [manager POST:@"http://beaconwallet.apiary-mock.com/transactions/payment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"JSON: %@", responseObject);
                    
                    //send the receipt
                    [self.discoveredPeripheral writeValue:operation.responseData
                                        forCharacteristic:self.receiptCharacteristic
                                                     type:CBCharacteristicWriteWithResponse];    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                
                // Cancel our subscription to the characteristic
                [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            }
            
            // Otherwise, just add the data on to what we already have
            [self.payment appendData:characteristic.value];

        }
    }

}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"payment notification received");
        [self.discoveredPeripheral readValueForCharacteristic:self.paymentCharacteristic];
    } else {
        // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
    // We're disconnected, so start scanning again
    [self scan];
}

/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.discoveredPeripheral.isConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_CART_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_INVOICE_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_PAYMENT_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BEACON_WALLET_RECEIPT_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}

#pragma mark helper methods for data

- (NSData *) getInvoice {
    return [@"invoice" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) getReceipt {
    return [@"receipt" dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
