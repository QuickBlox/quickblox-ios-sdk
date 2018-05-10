//
//  QMBaseChatMediaAttachmentCell.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/07/17.
//
//

#import "QMChatCell.h"
#import <FFCircularProgressView/FFCircularProgressView.h>
#import "QMChatResources.h"
#import "QMMediaViewDelegate.h"

@interface UIButton (QMAnimated)

- (void)qm_setImage:(UIImage *)image
           animated:(BOOL)animated;
- (void)qm_setImage:(UIImage *)image;

@end

@interface QMBaseMediaCell : QMChatCell <QMMediaViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIButton *mediaPlayButton;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet FFCircularProgressView *circularProgress;

- (NSString *)timestampString:(NSTimeInterval)currentTime
                  forDuration:(NSTimeInterval)duration;

- (CALayer *)maskLayerFromImage:(UIImage *)image
                      withFrame:(CGRect)frame;

- (void)setCurrentTime:(NSTimeInterval)currentTime
              animated:(BOOL)animated;
@end


