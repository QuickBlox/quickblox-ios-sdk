//
//  Enums.h
//  Quickblox
//
//  Created by IgorKh on 1/11/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

enum QBVideoChatConferenceType{
    QBVideoChatConferenceTypeUndefined = 0,
    QBVideoChatConferenceTypeAudioAndVideo = 1,
    QBVideoChatConferenceTypeAudio = 2,
};

enum QBContactListItemStatus{
    QBContactListItemStatusOnline = 1,
    QBContactListItemStatusOffline = 0,
};

enum QBPresenseShow{
    QBPresenseShowAway = 1, // The entity or resource is temporarily away.
    QBPresenseShowChat = 2, // The entity or resource is actively interested in chatting.
    QBPresenseShowDND = 3, // The entity or resource is busy (dnd = "Do Not Disturb").
    QBPresenseShowXA = 4, // The entity or resource is away for an extended period (xa = "eXtended Away").
};

enum QBVideoChatState {
    QBVideoChatStateUnknown = 0,
    
    QBVideoChatStateCalling = 1,
    QBVideoChatStateAcceptCall = 2,
    
    QBVideoChatBinding = 3,
    QBVideoChatWaitingOpponentAddressSTUN = 4,
    QBVideoChatSendingDataSTUN = 5,
    
    QBSetupVideoAllocationInProgress = 6,
    QBSetupVideoAllocationDone = 7,
    QBSetupVideoSetupPermissionsInProgress = 8,
    QBSetupVideoSetupPermissionsDone = 9,
    
    QBSetupVideoSetupWaitingPeerAttempt = 10,
    QBSetupVideoSetupConnectionBindInProgress = 11,
    QBSetupVideoSetupConnectingToRelay = 12,
    
    QBSetupVideoWaitingOpponentDataTURN = 13,
    QBSetuoVideoSendingDataTURN = 14,
    
    QBVideoChatStateRejectCall = 15,
};
