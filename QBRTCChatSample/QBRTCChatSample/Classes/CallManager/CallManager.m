//
//  CallManager.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 17.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CallManager.h"
#import "IncomingCallViewController.h"
#import "CallViewController.h"
#import "ContainerViewController.h"
#import "ConnectionManager.h"
#import "QMSoundManager.h"
#import "SVProgressHUD.h"

NSString *const kCallViewControllerID = @"CallViewController";
NSString *const kIncomingCallViewControllerID = @"IncomingCallViewController";
NSString *const kContainerViewControllerID = @"ContainerViewController";

@interface CallManager ()

@property (weak, nonatomic, readonly) UIViewController *rootViewController;
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;
@property (strong, nonatomic) ContainerViewController *containerVC;

@property (strong, nonatomic) QBRTCSession *session;

@end

@implementation CallManager

@dynamic rootViewController;

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _mainStoryboard =
        [UIStoryboard storyboardWithName:@"Main"
                                  bundle:[NSBundle mainBundle]];
    }
    
    return self;
}

#pragma mark - RootViewController

- (UIViewController *)rootViewController {
    
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

#pragma mark - Public methods

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType {
    
    if (self.session) {
        return;
    }
    
    [QBSoundRouter.instance initialize];
    
    NSArray *opponentsIDs = [ConnectionManager.instance idsWithUsers:users];
    
    QBRTCSession *session =
    [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs  withConferenceType:conferenceType];
    
    if (session) {
        
        self.session = session;
        
        CallViewController *callVC =
        [self.mainStoryboard instantiateViewControllerWithIdentifier:kCallViewControllerID];
        
        callVC.session = self.session;
        NSAssert(!self.containerVC, @"Muste be nil");
        self.containerVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:kContainerViewControllerID];
        self.containerVC.viewControllers = @[callVC];
        self.containerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
       
        [self.rootViewController presentViewController:self.containerVC animated:YES completion:nil];
    }
    else {
        
        [SVProgressHUD showErrorWithStatus:@"Creating new session - Failure"];
    }
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    
    
    if (self.session) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.session = session;
    
    [QBSoundRouter.instance initialize];
    
    //Test bg mode
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        [self.session acceptCall:nil];
    }
    else {
        
        [QMSoundManager playRingtoneSound];
        
        IncomingCallViewController *incomingVC =
        [self.mainStoryboard instantiateViewControllerWithIdentifier:kIncomingCallViewControllerID];
        
        CallViewController *callVC =
        [self.mainStoryboard instantiateViewControllerWithIdentifier:kCallViewControllerID];
        
        NSAssert(!self.containerVC, @"Muste be nil");
        self.containerVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:kContainerViewControllerID];
        self.containerVC.viewControllers = @[incomingVC, callVC];
        
        incomingVC.session = session;
        callVC.session = session;
        
        [self.rootViewController presentViewController:self.containerVC
                                              animated:YES
                                            completion:nil];
    }
}

- (void)sessionWillClose:(QBRTCSession *)session {
    
    NSLog(@"session will close");
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session ) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [QBSoundRouter.instance deinitialize];
            self.session = nil;
            [self.containerVC dismissViewControllerAnimated:NO completion:nil];
            self.containerVC = nil;
        });
    }
}

@end
