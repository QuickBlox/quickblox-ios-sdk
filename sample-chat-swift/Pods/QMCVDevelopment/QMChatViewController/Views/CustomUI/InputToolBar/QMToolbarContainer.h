//
//  QMToolbarContainer.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/9/17.
//
//

#import <UIKit/UIKit.h>

@interface QMToolbarContainer : UIToolbar

- (void)addButton:(UIButton *_Nonnull)button
           action:(nullable void(^)(UIButton *_Nonnull sender))action;

@end
