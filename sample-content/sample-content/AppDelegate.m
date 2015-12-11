//
//  AppDelegate.m
//  sample-content
//
//  Created by Quickblox Team on 6/9/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "AppDelegate.h"
#import <QuickBlox/QuickBlox.h>

const NSUInteger kApplicationID = 32186;
NSString *const kAuthKey        = @"hZW5jgFxzOS2aCC";
NSString *const kAuthSecret     = @"HOvhKhWNeGgV8cF";
NSString *const kAcconuntKey    = @"7yvNe17TnjNUqDoPwfqp";

typedef void (^CompletionHandlerType)();

@interface AppDelegate ()

@property (nonatomic, strong) NSMutableDictionary* completionHandlers;
@property (nonatomic, strong) id observer;
@end

@implementation AppDelegate

- (NSMutableDictionary *)completionHandlers
{
    if (_completionHandlers == nil) {
        _completionHandlers = [NSMutableDictionary dictionary];
    }
    return _completionHandlers;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    //
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAcconuntKey];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)subscribeForPushNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;

    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Successfull response!");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Error response!");
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if ([QBSession currentSession].currentUser == nil) {
        [QBRequest logInWithUserLogin:@"sample_content" password:@"sample_content" successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
            [self subscribeForPushNotificationsWithDeviceToken:deviceToken];
        } errorBlock:^(QBResponse * _Nonnull response) {}];
    } else {
        [self subscribeForPushNotificationsWithDeviceToken:deviceToken];
    }
}

#pragma mark - Background Session

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [QBConnection restoreBackgroundSession];
    
    [self addCompletionHandler:completionHandler forSession:identifier];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Did receive remote notifications.");
    [QBConnection enableBackgroundSession];
    
    [QBConnection setDownloadTaskDidFinishDownloadingBlock:^NSURL * _Nullable(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, NSURL * _Nonnull location) {
        NSLog(@"Download finished!");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* fileName = [downloadTask.originalRequest.URL.lastPathComponent stringByAppendingString:@".jpg"];
        NSURL* url = [NSURL fileURLWithPath:[[paths firstObject] stringByAppendingPathComponent:fileName]];
        NSLog(@"Path: %@", url);

        return url;
    }];
    
    [QBConnection setURLSessionDidFinishBackgroundEventsBlock:^(NSURLSession * _Nullable session) {
        NSLog(@"URL session did finished background events.");
        if (session.configuration.identifier) {
            [self callCompletionHandlerForSession:session.configuration.identifier];
        }
    }];

    [QBRequest downloadFileWithUID:@"74d679ca65ae4fa2870cfda5bc0e75c700" successBlock:nil statusBlock:nil errorBlock:nil];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
{
    if ([self.completionHandlers objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [self.completionHandlers setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession: (NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlers objectForKey: identifier];
    
    if (handler) {
        [self.completionHandlers removeObjectForKey:identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
        
        handler();
    }
}

@end
