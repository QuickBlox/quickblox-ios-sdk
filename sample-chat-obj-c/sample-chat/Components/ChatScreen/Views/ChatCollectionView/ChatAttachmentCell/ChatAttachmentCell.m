//
//  ChatAttachmentCell.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatAttachmentCell.h"
#import "AttachmentDownloadManager.h"

@interface ChatAttachmentCell()

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) AttachmentDownloadManager *attachmentDownloadManager;
@end

@implementation ChatAttachmentCell


+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 15);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

- (void)setupAttachmentImageWithID:(NSString *)ID {
    
    if ([self.attachmentID isEqualToString: ID] == NO) {
        return;
    }
    
    self.attachmentDownloadManager = [[AttachmentDownloadManager alloc] init];
    
    __weak typeof(self)weakSelf = self;
    [self.attachmentDownloadManager downloadAttachmentWithID:ID progressHandler:^(CGFloat progress, NSString * _Nonnull ID) {
        [weakSelf updateLoadingProgress:progress];
    } successHandler:^(UIImage * _Nonnull image, NSString * _Nonnull ID) {
        [weakSelf setupAttachmentImage:image];
    } errorHandler:^(NSError * _Nonnull error, NSString * _Nonnull ID) {
        UIImage *errorImage = [UIImage imageNamed:@"error_image"];
        [weakSelf setupAttachmentImage:errorImage];
    }];
}

- (void)setupAttachmentImage:(UIImage *)attachmentImage {
    self.progressLabel.hidden = YES;
    self.attachmentImageView.image = attachmentImage;
    self.attachmentImageView.layer.cornerRadius = 3.0f;
    self.attachmentImageView.layer.masksToBounds = YES;
}

- (void)updateLoadingProgress:(CGFloat)progress {
    if (progress > 0.0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressLabel.hidden = NO;
            weakSelf.progressLabel.text = [NSString stringWithFormat: @"%2.0f %%", progress * 100.0];
            if (progress > 0.99) {
                weakSelf.progressLabel.hidden = YES;
            }
        });
    }
}

- (void)prepareForReuse {
    self.attachmentImageView.image = nil;
}

@end
