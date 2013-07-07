//
//  Consts.h
//  Quickblox
//
//  Created by IgorKh on 2/6/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

// VideoChat Settings
extern NSString* const kQBVideoChatVideoFramesPerSecond;
extern NSString* const kQBVideoChatCallTimeout;
extern NSString* const kQBVideoChatBadConnectionTimeout;
extern NSString* const kQBVideoChatTURNServerEndPoint;
extern NSString* const kQBVideoChatFrameQualityPreset;
extern NSString* const kQBVideoChatWriteQueueMaxVideoOperationsThreshold;
extern NSString* const kQBVideoChatWriteQueueMaxAudioOperationsThreshold;
extern NSString* const kQBVideoChatP2PTimeout;


// video chat control messages
#define qbvideochat_pattern @"qbvideochat_"
#define qbvideochat_call @"qbvideochat_call"
#define qbvideochat_acceptCall @"qbvideochat_acceptCall"
#define qbvideochat_rejectCall @"qbvideochat_rejectCall"
#define qbvideochat_stopCall @"qbvideochat_stopCall"
#define qbvideochat_sendPublicAddress @"qbvideochat_sendPublicAddress"
#define qbvideochat_sendTURNRelayAddress @"qbvideochat_sendTURNRelayAddress"


// TCP/UDP video/audio packets tags
#define sendUDPAudioDataTag 7007
#define sendUDPVideoDataTag 3007
#define writeTCPAudioDataTag 7001
#define writeTCPVideoDataTag 5001


// TCP socket type
#define qbTCPSocketType1_ControlSocket 1
#define qbTCPSocketType2_DataSocketConnectedDirectToRelay 2
#define qbTCPSocketType3_DataSocketConnectedDirectToTURNServer 3


// Connection progress
//
#define qbChatConnectionTotalSteps 21
//
//
#define qbChatConnectionStep1AcceptedCall 1
//
#define qbChatConnectionStep2ConnectingToTURNServer 2
#define qbChatConnectionStep3ConnectedToTURNServer 3
//
#define qbChatConnectionStep4SentBuindingRequestToTURNServer 4
#define qbChatConnectionStep5ReceivedBuindingResponseFromTURNServer 5
//
#define qbChatConnectionStep6SentPublicAddressToOpponent 6
#define qbChatConnectionStep7ReceivedOpponentPublicAddress 7
//
#define qbChatConnectionStep8SentAllocationRequestToTURNServer 8
#define qbChatConnectionStep9ReceivedAllocationResponseFromTURNServer 9
//
#define qbChatConnectionStep10SentPermissionRequestToTURNServer 10
#define qbChatConnectionStep11ReceivedPermissionResponseFromTURNServer 11
#define qbChatConnectionStep12SentRelayAddressToOpponent 12
#define qbChatConnectionStep13ReceivedOpponentRelayAddress 13
//
#define qbChatConnectionStep14ConnectingToRelayAddress 14
#define qbChatConnectionStep15ConnectedToRelayAddress 15
#define qbChatConnectionStep16ReceivedConnectionAttemptMessageFromTURNServer 16
//
#define qbChatConnectionStep17ConnectingToTURNServer 17
#define qbChatConnectionStep18ConnectedToTURNServer 18
//
#define qbChatConnectionStep19SentConnectionBindRequestToTURNServer 19
#define qbChatConnectionStep20ReceivedConnectionBindResponseFromTURNServer 20
//
#define qbChatConnectionStep21ConnectionEstablishedSuccessfuly 21


