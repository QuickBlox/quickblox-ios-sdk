//
//  CallManager.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 17.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CallManager.h"
#import "IncomingCallViewController.h"
#import "VideoCallViewController.h"
#import "ContainerViewController.h"
#import "ConnectionManager.h"
#import "QMSoundManager.h"

NSString *const kVideoCallViewControllerIdentifier = @"VideoCallViewController";
NSString *const kIncomingCallViewController = @"IncomingCallViewController";
NSString *const kContainerViewControllerIdentifier = @"ContainerViewController";

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
        
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                    bundle:[NSBundle mainBundle]];
    }
    
    return self;
}

#pragma mark - Container VC

- (ContainerViewController *)containerVC {
    
    if (!_containerVC) {
        
        _containerVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:kContainerViewControllerIdentifier];
    }
    
    return _containerVC;
}

#pragma mark - RootViewController

- (UIViewController *)rootViewController {
    
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

#pragma mark - Public methods

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType {
    
    NSArray *opponentsIDs = [ConnectionManager.instance idsWithUsers:users];
    
    self.session =
    [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                   withConferenceType:conferenceType];
    
    VideoCallViewController *videoCallVC =
    [self.mainStoryboard instantiateViewControllerWithIdentifier:kVideoCallViewControllerIdentifier];
    
    videoCallVC.session = self.session;
    
    self.containerVC.viewControllers = @[videoCallVC];
    self.containerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.rootViewController presentViewController:self.containerVC
                                          animated:YES
                                        completion:nil];
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveDialingFromSession:(QBRTCSession *)session {
    
    [QMSoundManager playRingtoneSound];
}

- (void)didReceiveNewCallWithSession:(QBRTCSession *)session {
    
    if (self.session) {
     
        [session rejectCall:@{@"reason" : @""}];
        return;
    }
    
    self.session = session;
    
    [QMSoundManager playRingtoneSound];
    
    IncomingCallViewController *incomingVC =
    [self.mainStoryboard instantiateViewControllerWithIdentifier:kIncomingCallViewController];
    
    VideoCallViewController *videoCallVC =
    [self.mainStoryboard instantiateViewControllerWithIdentifier:kVideoCallViewControllerIdentifier];
    
    self.containerVC.viewControllers = @[incomingVC, videoCallVC];
    
    incomingVC.session = session;
    videoCallVC.session = session;
    
    [self.rootViewController presentViewController:self.containerVC
                                          animated:YES
                                        completion:nil];
}

- (void)sessionEnded:(QBRTCSession *)session {
    
    self.session = nil;
    [self.containerVC dismissViewControllerAnimated:NO completion:nil];
    self.containerVC = nil;
}

@end
