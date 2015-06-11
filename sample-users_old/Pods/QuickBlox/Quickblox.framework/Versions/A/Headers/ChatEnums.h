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

enum QBPresenseSubscriptionState{
    QBPresenseSubscriptionStateNone = 1, // the user does not have a subscription to the contact's presence information, and the contact does not have a subscription to the user's presence information
    QBPresenseSubscriptionStateTo = 2, // the user has a subscription to the contact's presence information, but the contact does not have a subscription to the user's presence information
    QBPresenseSubscriptionStateFrom = 3, // the contact has a subscription to the user's presence information, but the user does not have a subscription to the contact's presence information
    QBPresenseSubscriptionStateBoth = 4, //  both the user and the contact have subscriptions to each other's presence information
};


enum QBChatDialogType {
    QBChatDialogTypePublicGroup = 1,
    QBChatDialogTypeGroup = 2,
    QBChatDialogTypePrivate = 3,
};

enum QBChatHistoryMessageType {
    QBChatHistoryMessageTypeText = 1
};

