//
//  ChatAttachmentCell.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatAttachmentCell : ChatCell

/**
 *  Unique attachment identifier
 */
@property (nonatomic, strong) NSString *attachmentID;

/**
 *  Sets attachment image to cell
 *
 *  @param attachmentImage UIImage object
 */
- (void)setupAttachmentImageWithID:(NSString *)ID;

@property (nonatomic, weak) IBOutlet UIImageView *attachmentImageView;

@end

NS_ASSUME_NONNULL_END
