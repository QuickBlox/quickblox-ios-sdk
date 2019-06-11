//
//  AttachmentBar.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AttachmentBar;

@protocol AttachmentBarDelegate <NSObject>

- (void)attachmentBar:(AttachmentBar *)attachmentBar didUpLoadAttachment:(QBChatAttachment *)attachment;
- (void)attachmentBarFailedUpLoadImage:(AttachmentBar *)attachmentBar;
- (void)attachmentBar:(AttachmentBar *)attachmentBar didTapCancelButton:(UIButton *)sender;

@end

@interface AttachmentBar : UIView

@property (weak, nonatomic, nullable) id<AttachmentBarDelegate> delegate;

- (void)uploadAttachmentImage:(UIImage *)image pickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType;

@end

NS_ASSUME_NONNULL_END
