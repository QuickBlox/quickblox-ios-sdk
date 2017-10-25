//
//  QMAudioOutgoingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMAudioOutgoingCell.h"

@implementation QMAudioOutgoingCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(0, 0, 0, 8),
    defaultLayoutModel.staticContainerSize = CGSizeMake(182, 48);
    
    return defaultLayoutModel;
}
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    _progressView.layer.masksToBounds = YES;
    self.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    [self.progressView setProgress:0
                          animated:NO];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIImage *stretchableImage = self.containerView.backgroundImage;

    _progressView.layer.mask = [self maskLayerFromImage:stretchableImage withFrame:_progressView.bounds];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    
    [super setCurrentTime:currentTime];
    
    NSTimeInterval duration = self.duration;
    NSString *timeStamp = [self timestampString:currentTime
                                    forDuration:duration];
    
    self.durationLabel.text = timeStamp;
    
    if (duration > 0) {
        BOOL animated = self.viewState == QMMediaViewStateActive && currentTime > 0;
        [self.progressView setProgress:currentTime/duration
                              animated:animated];
    }
}

@end
