//
//  QMChatAttachmentOutgoingCell.h
//  QMChatViewController
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCell.h"
#import "QMChatAttachmentCell.h"

/**
 *  Outgoing attachment message cell class.
 */
@interface QMChatAttachmentOutgoingCell : QMChatCell<QMChatAttachmentCell>

/**
 *  Attachment image view.
 */
@property (nonatomic, weak) IBOutlet UIImageView *attachmentImageView;

@end
