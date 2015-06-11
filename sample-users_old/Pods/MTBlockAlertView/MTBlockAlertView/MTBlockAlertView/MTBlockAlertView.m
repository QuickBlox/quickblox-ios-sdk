//
//  MTBlockAlertView.m
//  MTBlockAlertView
//
//  Created by Parker Wightman on 8/17/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "MTBlockAlertView.h"

@implementation MTBlockAlertView


#pragma mark Custom Initializers

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.delegate = self;
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.delegate = self;
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  completionHanlder:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))theHandler
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... {
  self = [super initWithTitle:title
                      message:message
                     delegate:self
            cancelButtonTitle:cancelButtonTitle
            otherButtonTitles: nil];
  if (self) {
    if (otherButtonTitles) {
      va_list args;
      va_start(args, otherButtonTitles);
      [self addButtonWithTitle:otherButtonTitles];
      id object = nil;
      do {
        object = va_arg(args, id);
        if (object) {
          [self addButtonWithTitle:object];
        }
      } while (object);
      va_end(args);
    }
    
    [self setDidDismissWithButtonIndexBlock:theHandler];
  }
  
  return self;
}

#pragma mark UIAlertViewDelegate methods (optional)

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_clickedButtonAtIndexBlock) {
        _clickedButtonAtIndexBlock(alertView, buttonIndex);
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_didDismissWithButtonIndexBlock) {
        _didDismissWithButtonIndexBlock(alertView, buttonIndex);
    }
}

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_willDismissWithButtonIndexBlock) {
        _willDismissWithButtonIndexBlock(alertView, buttonIndex);
    }
}

- (void) alertViewCancel:(UIAlertView *)alertView {
    if (_cancelBlock) {
        _cancelBlock(alertView);
    }
}

#pragma mark Convenience Methods

+ (void) showWithTitle:(NSString *)title
               message:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButtonTitle
      otherButtonTitle:(NSString *)otherButtonTitle
        alertViewStyle:(UIAlertViewStyle)alertViewStyle
       completionBlock:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))completionBlock {

    MTBlockAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:title
                                                                  message:message
                                                        completionHanlder:completionBlock
                                                        cancelButtonTitle:cancelButtonTitle
                                                        otherButtonTitles:otherButtonTitle, nil];
    
    alertView.alertViewStyle = alertViewStyle;
    
    [alertView show];
}

+ (void) showWithTitle:(NSString *)title
               message:(NSString *)message
       completionBlock:(void (^)(UIAlertView *alertView))completionBlock {

    void (^didDismissHandler)(UIAlertView *, NSInteger) = ^(UIAlertView *alertView, NSInteger index) {
        if (completionBlock) {
            completionBlock(alertView);
        }
    };
    MTBlockAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:title
                                                                  message:message
                                                        completionHanlder:didDismissHandler
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    alertView.delegate = alertView;
    
    [alertView show];
}

+ (void) showWithTitle:(NSString *)title
               message:(NSString *)message {

    MTBlockAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:title
                                                                  message:message
                                                        completionHanlder:NULL
                                                        cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.delegate = alertView;
    
    [alertView show];
}

@end
