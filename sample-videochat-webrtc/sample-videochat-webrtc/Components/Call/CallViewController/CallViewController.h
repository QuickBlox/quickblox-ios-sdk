//
//  CallViewController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallInfo.h"
#import "CallActionsBar.h"
#import "ParticipantsView.h"
#import "CallTimerView.h"
#import "CallGradientView.h"
#import "MediaController.h"
#import "MediaListener.h"
#import "CallPermissions.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CallHangUpAction)(NSString *callId);
typedef void(^OnDismissAction)(void);

@interface CallViewController : UIViewController

@property (nullable, strong, nonatomic) CallInfo *callInfo;

@property (nullable, strong, nonatomic) MediaListener *mediaListener;
@property (nullable, strong, nonatomic) MediaController *mediaController;

@property (nullable, nonatomic, readwrite, copy) CallHangUpAction hangUp;

@property (weak, nonatomic) IBOutlet CallGradientView *headerView;
@property (weak, nonatomic) IBOutlet CallGradientView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *statsButton;
@property (weak, nonatomic) IBOutlet CallActionsBar *actionsBar;

@property (weak, nonatomic) IBOutlet ParticipantsView *participantsView;
@property (weak, nonatomic) IBOutlet CallTimerView *callTimer;

/// @param members: The call participants without a current user. The key is a user id and the value is a user name.
- (void)setupWithCallId:(NSString *)callId
                members:(NSDictionary<NSNumber *, NSString *>*)members
          mediaListener:(MediaListener *)mediaListener
         mediaController:(MediaController *)mediaController
              direction:(CallDirection)direction;

- (void)checkCallPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(СheckPermissionsCompletion _Nullable)completion;

- (void)endCall;

@end

NS_ASSUME_NONNULL_END
