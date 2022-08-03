//
//  InputContainer.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 01.12.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class InputContainer;

@protocol InputContainerDelegate <NSObject>
- (void)inputContainer:(InputContainer *)inputContainer didChangeValidState:(BOOL)isValid;
@end

@interface InputContainer : UIView
@property (nonatomic, weak) id <InputContainerDelegate> delegate;
- (void)setupWithTitle:(NSString *)title hint:(NSString *)hint regexes:(NSArray<NSString *> *)regularExpressions;
- (void)setInputEnabled:(BOOL)inputEnabled;
- (void)inputTextfieldBecomeFirstResponder;
- (NSString *)text;
- (BOOL)isValid;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
