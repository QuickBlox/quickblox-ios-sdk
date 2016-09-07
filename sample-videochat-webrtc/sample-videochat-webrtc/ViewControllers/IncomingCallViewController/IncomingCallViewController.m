//
//  IncomingCallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "IncomingCallViewController.h"
#import "QBButton.h"
#import "QMSoundManager.h"
#import "QBToolBar.h"
#import "QBButtonsFactory.h"
#import "CornerView.h"
#import "UsersDataSource.h"

@interface IncomingCallViewController () <QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView *callInfoTextView;
@property (weak, nonatomic) IBOutlet QBToolBar *toolbar;
@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (strong, nonatomic) NSArray *users;

@property (weak, nonatomic) NSTimer *dialignTimer;

@end

@implementation IncomingCallViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [QMSoundManager playRingtoneSound];
    
    [QBRTCClient.instance addDelegate:self];
    NSMutableArray *users = [NSMutableArray array];
    
    for (NSNumber *uID in self.session.opponentsIDs) {
        
        QBUUser *user = [self.usersDatasource userWithID:uID.integerValue];
        
        if (!user) {
            user = [QBUUser user];
            user.ID = uID.integerValue;
        }
        
        [users addObject:user];
    }
    self.users = [users copy];
    
    [self confiugreGUI];
    
    self.dialignTimer =
    [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                     target:self
                                   selector:@selector(dialing:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)dialing:(NSTimer *)timer {
    
    [QMSoundManager playRingtoneSound];
}

#pragma mark - Update GUI

- (void)confiugreGUI {
    
    [self defaultToolbarConfiguration];
    [self updateOfferInfo];
    [self updateCallInfo];
    
    self.title = [NSString stringWithFormat:@"Logged in as %@", [QBChat instance].currentUser.fullName] ;

}

- (void)defaultToolbarConfiguration {
    
    self.toolbar.backgroundColor = [UIColor clearColor];
    __weak __typeof(self)weakSelf = self;
    
    [self.toolbar addButton:[QBButtonsFactory circleDecline] action: ^(UIButton *sender) {
        
        [weakSelf cleanUp];
        [weakSelf.delegate incomingCallViewController:weakSelf didRejectSession:weakSelf.session];
    }];
    
    [self.toolbar addButton:[QBButtonsFactory answer] action: ^(UIButton *sender) {
        
        [weakSelf cleanUp];
        [weakSelf.delegate incomingCallViewController:weakSelf didAcceptSession:weakSelf.session];
    }];
    
    
    [self.toolbar updateItems];
}

- (void)updateOfferInfo {
    
    QBUUser *caller = [self.usersDatasource userWithID:self.session.initiatorID.unsignedIntegerValue];
    
    self.colorMarker.bgColor = [UIColor grayColor];
    self.colorMarker.title = caller.fullName;
    self.colorMarker.fontSize = 30.f;
}

- (void)updateCallInfo {
    
    NSMutableArray *info = [NSMutableArray array];
    
    for (QBUUser *user in self.users ) {
        
        [info addObject:[NSString stringWithFormat:@"%@(ID %@)", user.fullName, @(user.ID)]];
    }
    
    self.callInfoTextView.text = [info componentsJoinedByString:@", "];
    self.callInfoTextView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19];
    self.callInfoTextView.textAlignment = NSTextAlignmentCenter;
    
    NSString *text =
    self.session.conferenceType == QBRTCConferenceTypeVideo ? @"Incoming video call" : @"Incoming audio call";
    self.callStatusLabel.text = NSLocalizedString(text, nil);
}

#pragma mark - Actions

- (void)cleanUp {
    
    [self.dialignTimer invalidate];
    self.dialignTimer = nil;
    
    [QBRTCClient.instance removeDelegate:self];
	[QBRTCSoundRouter.instance deinitialize];
    [QMSysPlayer stopAllSounds];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (self.session == session) {
        [self cleanUp];
    }
}

@end
