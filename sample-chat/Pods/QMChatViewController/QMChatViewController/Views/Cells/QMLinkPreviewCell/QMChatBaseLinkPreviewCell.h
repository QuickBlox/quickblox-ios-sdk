//
//  QMChatBaseLinkPreviewCell.h
//
//
//  Created by Vitaliy Gurkovsky on 3/31/17.
//


#import "QMChatCell.h"
#import "QMImageView.h"
#import "QMLinkPreviewDelegate.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatBaseLinkPreviewCell : QMChatCell <QMLinkPreviewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *urlLabel;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *urlDescription;
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;

- (void)setSiteURL:(NSString *)siteURL
    urlDescription:(NSString *)urlDesription
      previewImage:(UIImage *)previewImage
           favicon:(UIImage *)favicon;

@end

NS_ASSUME_NONNULL_END
