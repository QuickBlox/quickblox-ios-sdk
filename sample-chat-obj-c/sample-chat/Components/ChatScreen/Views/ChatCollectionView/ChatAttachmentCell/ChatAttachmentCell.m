//
//  ChatAttachmentCell.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatAttachmentCell.h"
#import "AttachmentDownloadManager.h"
#import "CircularProgressBar.h"
#import "CALayer+Chat.h"

@interface ChatAttachmentCell()

@property (weak, nonatomic) IBOutlet CircularProgressBar *progressView;
@property (weak, nonatomic) IBOutlet UIView *forwardInfoView;
@property (weak, nonatomic) IBOutlet UIView *attachmentInfoView;
@property (nonatomic, strong) AttachmentDownloadManager *attachmentDownloadManager;
@property (nonatomic, strong) NSString *attachmentID;
@end

@implementation ChatAttachmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.previewContainer.layer applyShadowWithColor:[UIColor colorWithRed:0.85f green:0.98f blue:1.0f alpha:1.0f]
                                                       alpha:1.0f
                                                        forX:0.0f
                                                        forY:1.0f
                                                        blur:9.0f
                                                      spread:0.0f
                                                        path:nil];
    self.attachmentImageView.backgroundColor = [UIColor colorWithRed: 0.79f green: 0.8f blue: 0.79f alpha: 1.0f];
    self.attachmentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.infoTopLineView.backgroundColor = UIColor.clearColor;
    self.playImageView.hidden = YES;
    self.bottomInfoHeightConstraint.constant = 0.0f;
    self.forwardInfoHeightConstraint.constant = 0.0f;
    self.attachmentID = @"";
    self.attachmentSizeLabel.text = @"";
    self.progressView.hidden = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.typeAttachmentImageView.image = nil;
    self.attachmentImageView.image = nil;
    self.attachmentImageView.backgroundColor = [UIColor colorWithRed: 0.79f green: 0.8f blue: 0.79f alpha: 1.0f];
    self.attachmentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.infoTopLineView.backgroundColor = UIColor.clearColor;
    self.playImageView.hidden = YES;
    self.bottomInfoHeightConstraint.constant = 0.0f;
    self.forwardInfoHeightConstraint.constant = 0.0f;
    self.attachmentID = @"";
    self.attachmentSizeLabel.text = @"";
    self.progressView.hidden = YES;
}


+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    defaultLayoutModel.topLabelHeight = 15;
    defaultLayoutModel.timeLabelHeight = 15;
    
    return defaultLayoutModel;
}

- (void)setupAttachment:(QBChatAttachment *)attachment attachmentType:(AttachmentType)attachmentType completion:(_Nullable VideoURLCompletion)completion {
    if (!attachment.ID) {
        return;
    }
    
    self.attachmentID = attachment.ID;
    NSString *attachmentName = @"Attachment";
    if (attachment.name) {
        attachmentName = attachment.name;
    }
    
    self.attachmentDownloadManager = [[AttachmentDownloadManager alloc] init];
    
    __weak typeof(self)weakSelf = self;
    [self.attachmentDownloadManager downloadAttachmentWithID:self.attachmentID attachmentName:attachmentName attachmentType:attachmentType progressHandler:^(CGFloat progress, NSString * _Nonnull ID) {
        if (![self.attachmentID isEqualToString:ID]) {
            return;
        }
        self.userInteractionEnabled = NO;
        [self updateLoadingProgress: progress];
    } successHandler:^(UIImage * _Nullable image, NSURL * _Nullable url, NSString * _Nonnull ID) {
        if (![self.attachmentID isEqualToString:ID]) {
            return;
        }
        if (attachmentType == AttachmentTypeFile && url && image) {
            [weakSelf setupCellWithAttachment:attachment attachmentImage:image attachmentType:attachmentType];
            if (completion) {
                completion(url);
            }
        }
        if (attachmentType == AttachmentTypeVideo && url && image) {
            [weakSelf setupCellWithAttachment:attachment attachmentImage:image attachmentType:attachmentType];
            if (completion) {
                completion(url);
            }
        }
        if (attachmentType == AttachmentTypeImage && !url && image) {
            [weakSelf setupCellWithAttachment:attachment attachmentImage:image attachmentType:attachmentType];
        }
    } errorHandler:^(NSError * _Nonnull error, NSString * _Nonnull ID) {
        UIImage *errorImage = [UIImage imageNamed:@"image_attachment"];
        [weakSelf setupCellWithAttachment:attachment attachmentImage:errorImage attachmentType:AttachmentTypeError];
    }];
}

- (void)setupCellWithAttachment:(QBChatAttachment *)attachment attachmentImage:( UIImage * _Nullable )attachmentImage attachmentType:(AttachmentType)attachmentType {
    self.userInteractionEnabled = YES;
    self.progressView.hidden = YES;
    self.attachmentNameLabel.text = attachment.name;
    if (attachmentType == AttachmentTypeFile && attachmentImage != nil) {
        self.typeAttachmentImageView.image = nil;
        self.attachmentImageView.image = attachmentImage;
        self.attachmentImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.typeAttachmentImageView.image = nil;
        self.attachmentImageView.image = attachmentImage;
    }
}

- (void)updateLoadingProgress:(CGFloat)progress {
    if (self.progressView.isHidden == YES) {
        self.progressView.hidden = NO;
    } else if ((progress > 99) ) {
        self.progressView.hidden = YES;
    }
    if (progress > 0.0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressView setProgressTo:progress];
        });
    }
}

@end
