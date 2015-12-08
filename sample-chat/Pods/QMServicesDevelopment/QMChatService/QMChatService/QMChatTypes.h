//
//  QMChatTypes.h
//  QMServices
//
//  Created by Andrey Ivanov on 29.04.15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

typedef NS_ENUM(NSUInteger, QMMessageType) {
    /** Default message type*/
    QMMessageTypeText = 0,
    QMMessageTypeCreateGroupDialog = 1,
    QMMessageTypeUpdateGroupDialog = 2,
    
    QMMessageTypeContactRequest = 4,
    QMMessageTypeAcceptContactRequest,
    QMMessageTypeRejectContactRequest,
    QMMessageTypeDeleteContactRequest
};

typedef NS_ENUM(NSUInteger, QMMessageAttachmentStatus) {
    QMMessageAttachmentStatusNotLoaded = 0,
    QMMessageAttachmentStatusLoading,
    QMMessageAttachmentStatusLoaded,
    QMMessageAttachmentStatusError,
};

typedef NS_ENUM(NSUInteger, QMDialogUpdateType) {
    QMDialogUpdateTypePhoto     = 1,
    QMDialogUpdateTypeName      = 2,
    QMDialogUpdateTypeOccupants = 3
};