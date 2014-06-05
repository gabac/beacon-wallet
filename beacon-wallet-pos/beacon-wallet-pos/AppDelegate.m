//
//  AppDelegate.m
//  beacon-wallet-pos
//
//  Created by Fabian on 05.06.14.
//
//

#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
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
    
    // verify data signature
    NSString* data = @"{\"id\":42}";
    NSData* fileData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:@"CE3sX1gamLOrU5zzjXqL6Qck0G7u3XD5lQASD0DuIrAqfyXhvspklt1gd9VWzQCE/zyhvtQ95UzgHHtCCY2uucC4ezufEF+zT0ror822k+i6iCvTdhZ08BolOd6Ruumx2CuZ8PidmKpP84nJvk6+V7O6qm3sWZBZi4mTChc9knwWxuAEqg0Pczm7UjBeAVC2MIi6b0/jkS+yfXOExMTm5i65DfBfuDZuJ/B2PIl6wDb5P55ci1Z2nVjKexMy/YtpkrvapOAEhn25/R2hgoPLnYJFr+mMpP5rs3eZXT2jkA0KucoFd9JHfkfFSAZ6EjfIeKXqZTiYjyPBc1CMR07d0A==" options:0];
    
    uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([fileData bytes], [fileData length], sha1HashDigest);
    
    OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, sha1HashDigest, CC_SHA1_DIGEST_LENGTH, [signatureData bytes], [signatureData length]);
    
    if (verficationResult == errSecSuccess) {
        NSLog(@"Verified");
    } else {
        NSLog(@"Verification failed: %lu", verficationResult);
    }
    
    // encrypt data
    NSString* plainText = @"{\"nr\":\"1234567890\",\"pin\":\"1234\"}";
    NSData* plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    const size_t CIPHER_BUFFER_SIZE = 256;
    uint8_t cipherBuffer[CIPHER_BUFFER_SIZE];
    size_t cipherBufferSize = CIPHER_BUFFER_SIZE;
    
    OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, [plainTextData bytes], [plainTextData length], &cipherBuffer[0], &cipherBufferSize);
    NSData* encrypted = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    NSString* encryptedString = [encrypted base64EncodedStringWithOptions:0];
    NSLog(@"Encrypted %@", encryptedString);
    
    // clean up
    CFRelease(publicKey);
    CFRelease(trust);
    CFRelease(secPolicy);
    CFRelease(certificateFromFile);
    
    
    return YES;
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

@end
