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
NSString *const kAccountKey     = @"7yvNe17TnjNUqDoPwfqp";

typedef void (^CompletionHandlerType)(void);

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
    [QBSettings setAccountKey:kAccountKey];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)subscribeForPushNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;

    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Subscribed successfully!");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Create subscription error: %@", response.error);
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if ([QBSession currentSession].currentUser == nil) {
        [QBRequest logInWithUserLogin:@"sample_content" password:@"sample_content"
                         successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
            [self subscribeForPushNotificationsWithDeviceToken:deviceToken];
        } errorBlock:^(QBResponse * _Nonnull response) {
            NSLog(@"Login error: %@", response.error);
        }];
    } else {
        [self subscribeForPushNotificationsWithDeviceToken:deviceToken];
    }
}

#pragma mark - Background Session Download support

// Refer to this guide https://www.objc.io/issues/5-ios7/multitasking/#nsurlsessiondownloadtask

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(nonnull void (^)(void))completionHandler
{
    // You must re-establish a reference to the background session,
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session.
    [QBConnection restoreBackgroundSession];
    
    // Store the completion handler to update your UI after processing session events
    [self addCompletionHandler:completionHandler forSession:identifier];
}

// This sample handles Push Notifications with content from admin panel
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Must be setBlock that is fired when download finished.
    [QBConnection setDownloadTaskDidFinishDownloadingBlock:^NSURL * _Nullable(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, NSURL * _Nonnull location) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* fileName = downloadTask.originalRequest.URL.lastPathComponent;
        NSURL* url = [NSURL fileURLWithPath:[[paths firstObject] stringByAppendingPathComponent:fileName]];

        return url;
    }];
    
    // Block that is fired when all background events are finished,
    [QBConnection setURLSessionDidFinishBackgroundEventsBlock:^(NSURLSession * _Nullable session) {
        if (session.configuration.identifier) {
            [self callCompletionHandlerForSession:session.configuration.identifier];
        }
    }];
    
    // Request that uses background session to upload task.
    [QBRequest backgroundDownloadFileWithID:[userInfo[@"rich_content"] integerValue] successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
        NSLog(@"Download succeded!");
    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
        NSLog(@"Progress: %f", status.percentOfCompletion);
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Download error: %@", response.error);
    }];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
{
    if ([self.completionHandlers objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier. This should not happen.\n");
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
