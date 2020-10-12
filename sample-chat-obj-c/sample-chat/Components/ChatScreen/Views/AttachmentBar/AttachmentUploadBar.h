//
//  AttachmentUploadBar.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressBar.h"
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN
@class AttachmentUploadBar;

@protocol AttachmentBarDelegate <NSObject>

- (void)attachmentBar:(AttachmentUploadBar *)attachmentBar didUpLoadAttachment:(QBChatAttachment *)attachment;
- (void)attachmentBarFailedUpLoadImage:(AttachmentUploadBar *)attachmentBar;
- (void)attachmentBar:(AttachmentUploadBar *)attachmentBar didTapCancelButton:(UIButton *)sender;

@end

@interface AttachmentUploadBar : UIView
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImageView;
@property (weak, nonatomic) IBOutlet CircularProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic, nullable) id<AttachmentBarDelegate> delegate;

- (void)uploadAttachmentImage:(UIImage *)image pickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType;

@end

NS_ASSUME_NONNULL_END
