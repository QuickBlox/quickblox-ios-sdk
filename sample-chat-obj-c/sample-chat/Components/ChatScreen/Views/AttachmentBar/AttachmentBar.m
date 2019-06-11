//
//  AttachmentBar.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentBar.h"
#import "UIImage+fixOrientation.h"

@interface AttachmentBar()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@end

@implementation AttachmentBar
    
//MARK: - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}
    
//MARK - Setup
- (void)setupView {
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    
    self.progressLabel = [[UILabel alloc] init];
    [self.imageView addSubview:self.progressLabel];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:self.cancelButton];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20.0f].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10.0f].active = YES;
    [self.imageView.widthAnchor constraintEqualToConstant:80.0f].active = YES;
    [self.imageView.heightAnchor constraintEqualToConstant:80.0f].active = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.cornerRadius = 8.0f;
    self.imageView.layer.masksToBounds = YES;
    
    [self.progressLabel.leftAnchor constraintEqualToAnchor:self.imageView.leftAnchor].active = YES;
    [self.progressLabel.rightAnchor constraintEqualToAnchor:self.imageView.rightAnchor].active = YES;
    [self.progressLabel.centerYAnchor constraintEqualToAnchor:self.imageView.centerYAnchor].active = YES;
    [self.progressLabel.heightAnchor constraintEqualToConstant:40.0f].active = YES;
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.font = [UIFont systemFontOfSize:16.0f];
    self.progressLabel.textColor = [UIColor whiteColor];
    
    [self.cancelButton.rightAnchor constraintEqualToAnchor:self.imageView.rightAnchor constant:-4.0f].active = YES;
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.imageView.topAnchor constant:2.0f].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:24.0f].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:24.0f].active = YES;
    [self.cancelButton setImage:[UIImage imageNamed:@"ic_cancel"] forState:UIControlStateNormal];
    [self.cancelButton setTintColor:[UIColor whiteColor]];
    [self.cancelButton setEnabled:YES];
    [self.cancelButton setHidden:YES];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)cancelButtonPressed:(UIButton *)sender {
    self.cancelButton.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(attachmentBar:didTapCancelButton:)]) {
        [self.delegate attachmentBar:self didTapCancelButton:sender];
    }
}

- (void)updateLoadingProgress:(CGFloat)progress {
    if (progress > 0.0) {
        self.progressLabel.hidden = NO;
        self.progressLabel.text = [NSString stringWithFormat:@"%2.0f %%", progress * 100.0];
    }
        if (progress > 0.99) {
            self.progressLabel.hidden = YES;
            self.cancelButton.hidden = NO;
        }
}

/**
 *  This method is called when the user finishes picking attachment image.
 *
 *  @param image    image that was picked by user
 */
- (void)uploadAttachmentImage:(UIImage *)image pickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    self.imageView.image = image;
    self.cancelButton.hidden = YES;
    
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
                          
                          attachment.url = uploadedBlob.privateUrl ? uploadedBlob.privateUrl : uploadedBlob.publicUrl;
                          
                          attachment.ID = uploadedBlob.UID;
                          attachment.name = uploadedBlob.name;
                          attachment.type = @"image";
                          
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
