//
//  IncomingCallViewController.m
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "IncomingCallViewController.h"
#import "CornerView.h"
#import "QBButton.h"
#import "QMSoundManager.h"
#import "QBToolBar.h"
#import "QBButtonsFactory.h"
#import "Settings.h"
#import "SampleCore.h"
#import "SampleCoreManager.h"
#import "UsersDataSourceProtocol.h"

@interface IncomingCallViewController () <QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView *callInfoTextView;
@property (weak, nonatomic) IBOutlet QBToolBar *toolbar;
@property (weak, nonatomic) IBOutlet CornerView *colorMarker;

@property (weak, nonatomic) NSTimer *dialingTimer;

@end

@implementation IncomingCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [QMSoundManager playRingtoneSound];
    
    [[QBRTCClient instance] addDelegate:self];
    self.users = [[SampleCore usersDataSource] usersWithIDS:self.session.opponentsIDs];
    [self configureGUI];
    
    self.dialingTimer =
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

- (void)configureGUI {
    
    [self defaultToolbarConfiguration];
    [self updateOfferInfo];
    [self updateCallInfo];
    
    self.title = [NSString stringWithFormat:@"Logged in as %@", [SampleCore usersDataSource].currentUser.fullName];
    [self setDefaultBackBarButtonItem:^{
        
    }];
}

- (void)defaultToolbarConfiguration {
	
	if ([SampleCore settings].autoAcceptCalls) {
		// auto accept call for UI tests
		[self cleanUp];
		[self.delegate incomingCallViewController:self didAcceptSession:self.session];
		
		return;
	}
	
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
    
    QBUUser *caller = [[SampleCore usersDataSource] userWithID:self.session.initiatorID];
	
	self.colorMarker.bgColor = [[SampleCore usersDataSource] colorAtUser:caller];
	
	NSString *userInfo = [[[caller fullName] substringToIndex:1] uppercaseString];
	
	if (!userInfo) {
		userInfo = [self.session.initiatorID stringValue];
	}
	
	self.colorMarker.title = userInfo;
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
    
    [self.dialingTimer invalidate];
    self.dialingTimer = nil;
	
	[SampleCoreManager instance].hasActiveCall = NO;
	
    [[QBRTCClient instance] removeDelegate:self];
    [QMSysPlayer stopAllSounds];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
      [self cleanUp];
}

@end
