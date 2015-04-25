//
//  QBChatDialog.h
//  Quickblox
//
//  Created by Igor Alefirenko on 23/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEnums.h"

@class QBChatRoom;

@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/** Object ID */
@property (nonatomic, retain) NSString *ID;

/** Created date */
@property (nonatomic, retain) NSDate *createdAt;

/** Room JID. If private chat, room JID will be nil */
@property (nonatomic, retain) NSString *roomJID;

/** Chat type: Private/Group/PublicGroup */
@property (nonatomic) enum QBChatDialogType type;

/** Group chat name. If chat type is private, name will be nil */
@property (nonatomic, retain) NSString *name;

/** Group chat photo. Can contain a link to a file in Content module, Custom Objects module or just a web link. */
@property (nonatomic, retain) NSString *photo;

/** Last message text in private or group chat */
@property (nonatomic, retain) NSString *lastMessageText;

/** Date of last message in private or group chat */
@property (nonatomic, retain) NSDate *lastMessageDate;

/** User ID of last opponent in private or group chat */
@property (nonatomic, assign) NSUInteger lastMessageUserID;

/** Number of unread messages in this dialog */
@property (nonatomic, assign) NSUInteger unreadMessagesCount;

/** Array of user ids in chat. For private chat count = 2 */
@property (nonatomic, retain) NSArray *occupantIDs;

/** The dictionaty with data */
@property (nonatomic, retain) NSDictionary *data;

/** Dialog owner */
@property (nonatomic, assign) NSUInteger userID;

/** ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise or if you aren't logged in to Chat.  */
@property (nonatomic, readonly) NSInteger recipientID;

/** Returns an autoreleased instance of QBChatRoom to join if type = QBChatDialogTypeGroup or QBChatDialogTypePublicGroup. nil otherwise. */
@property (nonatomic, readonly) QBChatRoom *chatRoom;


/** Constructor */
- (instancetype)initWithDialogID:(NSString *)dialogID;

/** Occupants ids to push. Use for update dialog */
- (void)setPushOccupantsIDs:(NSArray *)occupantsIDs;
- (NSArray *)pushOccupantsIDs;

/** Occupants ids to pull. Use for update dialog */
- (void)setPullOccupantsIDs:(NSArray *)occupantsIDs;
- (NSArray *)pullOccupantsIDs;


@end
