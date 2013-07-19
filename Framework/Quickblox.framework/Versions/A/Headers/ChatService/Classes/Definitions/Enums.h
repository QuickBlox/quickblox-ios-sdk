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