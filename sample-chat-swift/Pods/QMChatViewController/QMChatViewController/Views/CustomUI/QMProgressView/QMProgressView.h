//
//  QMProgressView.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/20/17.
//
//

#import <UIKit/UIKit.h>

@interface QMProgressView : UIView

@property (assign, nonatomic, readonly) CGFloat progress;

@property (strong, nonatomic) UIColor *progressBarColor;

- (void)setProgress:(CGFloat)progress
           animated:(BOOL)animated;

@end
