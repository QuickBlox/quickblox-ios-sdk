//
//  QMAudioRecordButton.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/6/17.
//
//

#import <UIKit/UIKit.h>

@protocol QMAudioRecordButtonProtocol;

@interface QMAudioRecordButton : UIButton

@property (nonatomic, weak) id <QMAudioRecordButtonProtocol> delegate;

@property (nonatomic, strong) UIImageView *iconView;

- (void)animateIn;
- (void)animateOut;

@end


@protocol QMAudioRecordButtonProtocol <NSObject>

- (void)recordButtonInteractionDidBegin;
- (void)recordButtonInteractionDidCancel:(CGFloat)velocity;
- (void)recordButtonInteractionDidComplete:(CGFloat)velocity;
- (void)recordButtonInteractionDidUpdate:(CGFloat)velocity;
- (void)recordButtonInteractionDidStopped;

@end
