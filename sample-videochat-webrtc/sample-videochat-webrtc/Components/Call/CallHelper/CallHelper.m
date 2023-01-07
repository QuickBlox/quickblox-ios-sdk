//
//  CallHelper.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 20.07.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallHelper.h"
#import "SessionsController.h"
#import "Log.h"
#import "CallPayload.h"
#import "MediaListener.h"
#import "MediaController.h"
#import "NSDate+Videochat.h"

@interface CallHelper ()

@property (nonatomic, strong) CallKitManager *callKit;
@property (nonatomic, strong) SessionsController *sessionsController;

@end

@interface CallHelper (ActiveSession) <SessionsControllerDelegate>
@end

@interface CallHelper (CallKit) <CallKitManagerDelegate>
@end


@implementation CallHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.callKit = [CallKitManager new];
        self.callKit.delegate = self;
        self.sessionsController = [SessionsController new];
        self.sessionsController.delegate = self;
    }
    return self;
}

- (MediaController *)generateMediaController {
    MediaController *mediaController = [[MediaController alloc] init];
    mediaController.delegate = self.sessionsController;
    self.callKit.actionDelegate = mediaController;
    return mediaController;
}

- (MediaListener *)generateMediaListener {
    MediaListener *mediaListener = [[MediaListener alloc] init];
    self.sessionsController.mediaListenerDelegate = mediaListener;
    return mediaListener;
}

- (NSString *)registeredCallId {
    return self.sessionsController.activeSessionId;
}

- (BOOL)callReceivedWithSessionId:(NSString *)sessionID {
    return [self.sessionsController session:sessionID confirmToState:SessionStateReceived];
}

- (void)registerCallWithPayload:(NSDictionary *)payload
                     completion:(void (^)(void))completion {
    CallPayload *call = [[CallPayload alloc] initWithPayload:payload];
    IncommingCallState state = IncommingCallStateValid;
    if (call.valid == NO) {
        state = IncommingCallStateInvalid;
    } else if (call.missed || [self.sessionsController session:call.sessionID confirmToState:SessionStateRejected]) {
        state = IncommingCallStateMissed;
    }
    if (self.callKit.callUUID && [self.sessionsController session:call.sessionID confirmToState:SessionStateNew])  {
        // when self.callKit.callUUID != nil
        // at that moment has the active call
        Log(@"[%@] Received a voip push with another session that has an active call at that moment.", NSStringFromClass(CallHelper.class));
        [self.sessionsController reject:call.sessionID userInfo:nil];
        return;
    }
    
    [self.callKit reportIncomingCall:call.sessionID
                               title:call.title
                            hasVideo:call.hasVideo
                               state:state
                          completion:completion];
    
    if (state != IncommingCallStateValid) {
        return;
    }
    
    [self.sessionsController activate:call.sessionID timestamp:call.timestamp];
    
    if ([self.delegate respondsToSelector:@selector(helper:didRegisterCall:mediaListener:mediaController:direction:members:hasVideo:)]) {
        [self.delegate helper:self
              didRegisterCall:call.sessionID
                mediaListener:[self generateMediaListener]
               mediaController:[self generateMediaController]
                    direction:CallDirectionIncoming
                      members:call.members
                     hasVideo:call.hasVideo];
    }
}

- (void)registerCallWithMembers:(NSDictionary<NSNumber *, NSString *>*)members
                       hasVideo:(BOOL)hasVideo {
    // Prepare call
    NSDictionary *payload = [self.sessionsController activateWithMembers:members
                                                                          hasVideo:hasVideo];
    if (!payload.count) {
        Log(@"[%@] You should login to use VideoChat API. Session hasn’t been created. Please try to relogin.", NSStringFromClass(CallHelper.class));
        return;
    }
        
    CallPayload *call = [[CallPayload alloc] initWithPayload:payload];
    
    //Showing CallKit screen
    [self.callKit reportOutgoingCall:call.sessionID
                               title:call.title
                            hasVideo:call.hasVideo
                          completion:nil];
    
    //Sending VOIP call event
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    NSString *message = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    //Determine participants who are offline to send them a VOIP Push
    for (NSNumber *member in members.allKeys) {
        [QBChat.instance pingUserWithID:member.unsignedIntValue timeout:3.0f completion:^(NSTimeInterval timeInterval, BOOL success) {
            if (success) {
                Log(@"[%@] Participant with id: %@ is online. There is no need to send a VoIP notification.",  NSStringFromClass(CallHelper.class), member);
                return;
            }
            QBMEvent *event = [QBMEvent event];
            event.notificationType = QBMNotificationTypePush;
            event.usersIDs = [NSString stringWithFormat:@"%@", member];
            event.type = QBMEventTypeOneShot;
            event.message = message;
            
            [QBRequest createEvent:event
                      successBlock:^(QBResponse *response, NSArray<QBMEvent *> *events) {
                Log(@"[%@] Send voip push to Participant with id: %@ - Success",  NSStringFromClass(CallHelper.class), member);
            } errorBlock:^(QBResponse * _Nonnull response) {
                
                Log(@"[%@] Send voip push to Participant with id: %@  - Error %@",  NSStringFromClass(CallHelper.class), member, response.error.description);
            }];
        }];
    }
    
    // Start call
    NSString *timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] currentTimestamp]];
    NSDictionary *userInfo = @{@"timestamp" : timeStamp};
    [self.sessionsController start:call.sessionID userInfo:userInfo];
    if ([self.delegate respondsToSelector:@selector(helper:didRegisterCall:mediaListener:mediaController:direction:members:hasVideo:)]) {
        [self.delegate helper:self
                  didRegisterCall:call.sessionID
                mediaListener:[self generateMediaListener]
               mediaController:[self generateMediaController]
                        direction:CallDirectionOutgoing
                          members:call.members
                         hasVideo:call.hasVideo];
    }
}

- (void)unregisterCall:(NSString *)callId
              userInfo:(NSDictionary<NSString *, NSString *>*)userInfo {
    [self.sessionsController reject:callId
                               userInfo:userInfo];
}

- (void)updateCall:(NSString *)callId title:(NSString *)title {
    [self.callKit reportUpdateCall:callId title:title];
}

@end

@implementation CallHelper (ActiveSession)

- (void)controller:(nonnull SessionsController *)controller didAcceptSession:(nonnull NSString *)sessionId {
    [self.callKit reportAcceptCall:sessionId];
}

- (void)controller:(nonnull SessionsController *)controller didEndWaitSession:(nonnull NSString *)sessionId {
    if ([self.delegate respondsToSelector:@selector(helper:didUnregisterCall:)]) {
        [self.delegate helper:self didUnregisterCall:sessionId];
    }
    [self.callKit reportEndCall:sessionId reason:CXCallEndedReasonUnanswered];
}

- (void)controller:(SessionsController *)controller
didCloseSession:(NSString *)sessionId {
    if ([self.delegate respondsToSelector:@selector(helper:didUnregisterCall:)]) {
        [self.delegate helper:self didUnregisterCall:sessionId];
    }
    [self.callKit reportEndCall:sessionId];
}

- (void)controller:(nonnull SessionsController *)controller didChangeAudioState:(BOOL)enabled session:(nonnull NSString *)sessionId {
    [self.callKit muteAudio:!enabled call:sessionId];
}

- (void)controller:(nonnull SessionsController *)controller didReceiveIncomingSession:(nonnull NSDictionary *)payload {
    [self registerCallWithPayload:payload completion:^{}];
}


@end

@implementation CallHelper (CallKit)

- (void)callKit:(nonnull CallKitManager *)callKit didEndCall:(nonnull NSString *)sessionId {
    // external ending using "reportEndCall" methods
}

- (void)callKit:(nonnull CallKitManager *)callKit didTapAnswer:(nonnull NSString *)sessionId {
    [self.sessionsController accept:sessionId userInfo:nil];
    if ([self.delegate respondsToSelector:@selector(helper:didAcceptCall:)]) {
        [self.delegate helper:self didAcceptCall:sessionId];
    }
}

- (void)callKit:(nonnull CallKitManager *)callKit didTapRedject:(nonnull NSString *)sessionId {    
    [self.sessionsController reject:sessionId userInfo:nil];
}


@end
