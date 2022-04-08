//
//  ChatAttachmentCell.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"
#import "AttachmentDownloadOperation.h"
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoURLCompletion)(NSURL *videoURl);

@interface ChatAttachmentCell : ChatCell

/**
 *  Sets attachment image to cell
 *
 *  @param attachmentImage UIImage object
 */
@property (nonatomic, weak) IBOutlet UIImageView *attachmentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forwardInfoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomInfoHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *forwardedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIImageView *typeAttachmentImageView;
@property (weak, nonatomic) IBOutlet UILabel *attachmentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachmentSizeLabel;
@property (weak, nonatomic) IBOutlet UIView *infoTopLineView;
@property (strong, nonatomic) NSURL *attachmentUrl;
- (void)setupAttachment:(QBChatAttachment *)attachment;
@end

NS_ASSUME_NONNULL_END
