//
//  ChatAttachmentOutgoingCell.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatCell.h"
#import "ChatAttachmentCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatAttachmentOutgoingCell : ChatAttachmentCell
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end

NS_ASSUME_NONNULL_END
