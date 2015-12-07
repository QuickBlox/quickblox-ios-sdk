//
//  QBChatAbstractMessage+QMCustomParameters.h
//  QMServices
//
//  Created by Andrey Ivanov on 24.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Quickblox/QBChatMessage.h>
#import "QMChatTypes.h"

@interface QBChatMessage (QMCustomParameters)
/**
 *  Message
 */
@property (strong, nonatomic) NSString *saveToHistory;
@property (assign, nonatomic) QMMessageType messageType;
@property (strong, nonatomic) NSString *chatMessageID;
@property (assign, nonatomic) BOOL messageDeliveryStatus;
@property (assign, nonatomic) QMMessageAttachmentStatus attachmentStatus;

/**
 *  Dialog
 */
@property (strong, nonatomic, readonly) QBChatDialog *dialog;
@property (assign, nonatomic) QMDialogUpdateType dialogUpdateType;
@property (strong, nonatomic) NSArray *currentOccupantsIDs;
@property (strong, nonatomic) NSArray *addedOccupantsIDs;
@property (strong, nonatomic) NSArray *deletedOccupantsIDs;
@property (strong, nonatomic) NSString *dialogName;
@property (strong, nonatomic) NSString *dialogPhoto;
@property (strong, nonatomic) NSDate *dialogUpdatedAt;

/**
 *  Save values from QBChatDialog to message custom parameters
 *
 *  @param dialog QBChatDialog that will be saved
 */
- (void)updateCustomParametersWithDialog:(QBChatDialog *)dialog;

/**
 *  This method is used to determine if the message data item contains text or media.
 *  If this method returns `YES`, an instance of `QMChatViewController` will ignore
 *  the `text` method of this protocol when dequeuing a `QMChatCollectionViewCell`
 *  and only call the `media` method.
 *
 *  Similarly, if this method returns `NO` then the `media` method will be ignored and
 *  and only the `text` method will be called.
 *
 *  @return A boolean value specifying whether or not this is a media message or a text message.
 *  Return `YES` if this item is a media message, and `NO` if it is a text message.
 */
- (BOOL)isMediaMessage;

/**
 *  This method is used to determine if the message data item is notification.
 *
 *  @return A boolean value specifying whether or not this is a notification message.
 *  Return `YES` if this item is a notification message, and `NO` if it is a text message.
 */
- (BOOL)isNotificatonMessage;

@end
