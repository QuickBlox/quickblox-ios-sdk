//
//  QMChatBaseLinkPreviewCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/31/17.
//
//

#import "QMLinkPreviewDelegate.h"
#import "QMChatBaseLinkPreviewCell.h"
#import "QMChatResources.h"
#import "QMImageLoader.h"
#import <AVFoundation/AVFoundation.h>

@interface QMChatBaseLinkPreviewCell() <QMImageViewDelegate>
@end

@implementation QMChatBaseLinkPreviewCell

//MARK: -  QMImageViewDelegate

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.urlDescription.layer.drawsAsynchronously = YES;
}

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    if ([self.delegate respondsToSelector:@selector(chatCellDidTapContainer:)]) {
        [self.delegate chatCellDidTapContainer:self];
    }
}

//MARK: -  QMLinkPreviewDelegate

- (void)setSiteURL:(NSString *)siteURL
   urlDescription:(NSString *)urlDesription
      previewImage:(UIImage *)previewImage
           favicon:(UIImage *)favicon {
    
    NSMutableAttributedString *resultHostString = [[NSMutableAttributedString alloc] init];
    
    if (favicon) {
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = favicon;
        
        UIFont *font = _urlLabel.font;
        CGFloat mid = font.descender + font.capHeight;
        
        CGSize imageSize = AVMakeRectWithAspectRatioInsideRect(favicon.size,
                                                               CGRectMake(0, 0, 12, 12)).size;
        attachment.bounds = CGRectIntegral(
                                           CGRectMake(0,
                                                      font.descender - imageSize.height / 2 + mid + 2,
                                                      imageSize.width,
                                                      imageSize.height));
        
        NSAttributedString *attachmentString =
        [NSAttributedString attributedStringWithAttachment:attachment];
   
        [resultHostString appendAttributedString:attachmentString];
    }
    
    NSString *hostSring = [NSString stringWithFormat:@" %@", [NSURL URLWithString:siteURL].host];
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : _urlLabel.textColor};
    NSAttributedString *host = [[NSAttributedString alloc] initWithString:hostSring attributes:attrs];
    [resultHostString appendAttributedString:host];
    
    self.urlLabel.attributedText = resultHostString;
    self.urlDescription.text = urlDesription;
    self.previewImageView.image = previewImage;
}

@end
