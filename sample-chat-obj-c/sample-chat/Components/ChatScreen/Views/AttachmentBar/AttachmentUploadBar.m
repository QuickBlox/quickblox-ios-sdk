//
//  AttachmentUploadBar.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentUploadBar.h"
#import "UIImage+fixOrientation.h"
#import "UIView+Chat.h"

@implementation AttachmentUploadBar

//MARK: - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cancelButton.hidden = YES;
    self.progressBar.hidden = YES;
    [self.attachmentImageView setRoundViewWithCornerRadius:8.0f];
    self.attachmentImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self setRoundBorderEdgeColorView:0.0f borderWidth:0.5f color:nil borderColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    self.cancelButton.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(attachmentBar:didTapCancelButton:)]) {
        [self.delegate attachmentBar:self didTapCancelButton:sender];
    }
}

- (void)updateLoadingProgress:(CGFloat)progress {
    if (self.progressBar.isHidden == YES) {
        self.progressBar.hidden = NO;
    }
    if (progress > 0.0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressBar setProgressTo:progress];
        });
    }
}

/**
 *  This method is called when the user finishes picking attachment image.
 *
 *  @param image    image that was picked by user
 */
- (void)uploadAttachmentImage:(UIImage *)image pickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    self.attachmentImageView.image = image;
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof(weakSelf)strongSelf = weakSelf;
        
        UIImage *newImage = image;
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
        CGFloat scaleCoefficient = largestSide / 560.0f;
        CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
        
        UIGraphicsBeginImageContext(newSize);
        
        [image drawInRect:(CGRect){0, 0, newSize.width, newSize.height}];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (resizedImage == nil) {
            return;
        }
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        // Sending attachment to the dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [QBRequest TUploadFile:imageData
                          fileName:@"test.png"
                       contentType:@"image/png"
                          isPublic:NO
                      successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull uploadedBlob) {
                
                QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
                attachment.ID = uploadedBlob.UID;
                attachment.name = uploadedBlob.name;
                attachment.type = @"image";
                
                self.progressBar.hidden = YES;
                self.cancelButton.hidden = NO;
                if ([strongSelf.delegate respondsToSelector:@selector(attachmentBar:didUpLoadAttachment:)]) {
                    [strongSelf.delegate attachmentBar:strongSelf didUpLoadAttachment:attachment];
                }
                
            } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
                
                CGFloat progress = status.percentOfCompletion;
                [strongSelf updateLoadingProgress:progress];
                
            } errorBlock:^(QBResponse * _Nonnull response) {
                if ([strongSelf.delegate respondsToSelector:@selector(attachmentBarFailedUpLoadImage:)]) {
                    [strongSelf.delegate attachmentBarFailedUpLoadImage:strongSelf];
                }
                
            }];
        });
    });
}

@end
