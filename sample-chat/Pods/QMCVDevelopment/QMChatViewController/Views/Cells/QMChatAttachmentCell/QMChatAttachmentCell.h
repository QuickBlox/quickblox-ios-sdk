//
//  QMChatAttachmentCell.h
//  QMChatViewController
//
//  Created by Injoit on 7/2/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

/**
 *  Protocol which describes required methods and properties for attachment cells.
 */
@protocol QMChatAttachmentCell <NSObject>

/**
 *  Unique attachment identifier
 */
@property (nonatomic, strong) NSString *attachmentID;

/**
 *  Sets attachment image to cell
 *
 *  @param attachmentImage UIImage object
 */
- (void)setAttachmentImage:(UIImage *)attachmentImage;

/**
 *  Updates progress label text
 *
 *  @param progress CGFloat value to set
 */
- (void)updateLoadingProgress:(CGFloat)progress;

@end
