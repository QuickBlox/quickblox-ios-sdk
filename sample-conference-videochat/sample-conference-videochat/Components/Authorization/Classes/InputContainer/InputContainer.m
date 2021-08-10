//
//  InputContainer.m
//  sample-conference-videochat
//
//  Created by Injoit on 01.12.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

#import "InputContainer.h"
#import "UITextField+Chat.h"
#import "UIColor+Chat.h"
#import "NSString+Chat.h"

static const CGFloat padding = 12.0f;
static const CGFloat cornerRadius = 4.0f;
NSString *const defaultColor = @"#DFEBFF";
NSString *const activeColor = @"#ACBFE2";

@interface InputContainer()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextfield;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
//MARK: - Properties
@property (assign, nonatomic) BOOL valid;
@property (strong, nonatomic) NSArray<NSString *> *regexes;
@property (strong, nonatomic) NSString *hint;
@end

@implementation InputContainer
// MARK: - Public Methods
- (NSString *)text {
    return self.inputTextfield.text;
}

- (void)setInputEnabled:(BOOL)inputEnabled {
    [self.inputTextfield setEnabled:inputEnabled];
}

- (void)inputTextfieldBecomeFirstResponder {
    [self.inputTextfield becomeFirstResponder];
}

- (void)setupWithTitle:(NSString *)title hint:(NSString *)hint regexes:(NSArray<NSString *> *)regexes {
    [self.inputTextfield addShadow:[UIColor colorWithHexString:defaultColor] cornerRadius:cornerRadius];
    [self.inputTextfield setPadding:padding isLeft:YES];
    self.titleLabel.text = title;
    self.hint = hint;
    self.hintLabel.text = @"";
    self.regexes = regexes;
    self.valid = NO;
}

- (BOOL)isValid {
    return self.valid;
}

//MARK: - Internal Methods
- (void)setValid:(BOOL)valid {
    _valid = valid;
    if ([self.delegate respondsToSelector:@selector(inputContainer:didChangeValidState:)]) {
        [self.delegate inputContainer:self didChangeValidState:valid];
    }
    if ((self.inputTextfield.text.length == 0 && self.inputTextfield.isFirstResponder == NO) || valid == YES) {
        self.hintLabel.text = @"";
    } else {
        self.hintLabel.text = self.hint;
    }
}

- (IBAction)editingDidBegin:(UITextField *)sender {
    [self validateTextField:sender];
    [sender addShadow:[UIColor colorWithHexString:activeColor] cornerRadius:cornerRadius];
}
- (IBAction)editingChanged:(UITextField *)sender {
    [self validateTextField:sender];
}
- (IBAction)editingDidEnd:(UITextField *)sender {
    [self validateTextField:sender];
    [sender addShadow:[UIColor colorWithHexString:defaultColor] cornerRadius:cornerRadius];
}

- (void)validateTextField:(UITextField *)texField {
    if (!texField.text) {
        self.valid = NO;
        return;
    }
    self.valid = [texField.text validateWithRegexes:self.regexes];
}

@end
