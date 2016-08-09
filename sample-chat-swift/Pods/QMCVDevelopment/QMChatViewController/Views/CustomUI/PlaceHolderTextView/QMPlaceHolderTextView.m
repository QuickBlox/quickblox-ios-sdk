//
//  QMPlaceHolderTextView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 13.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMPlaceHolderTextView.h"
#import "NSString+QM.h"

@implementation QMPlaceHolderTextView

#pragma mark - Initialization

- (void)configureTextView {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGFloat cornerRadius = 6.0f;
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = cornerRadius;
    
    self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0f, cornerRadius, 0.0f);
    
    self.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    self.contentInset = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
    
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    
    [self setDefaultSettings];
    
    self.placeHolderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    self.selectable = true;
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    [self addTextViewNotificationObservers];
}

- (void)setDefaultSettings {
    
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentNatural;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self configureTextView];
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureTextView];
}

- (void)dealloc {
    
    [self removeTextViewNotificationObservers];
}

#pragma mark - Composer text view

- (BOOL)hasText {
    
    return ([[self.text stringByTrimingWhitespace] length] > 0);
}

- (BOOL)hasTextAttachment {
    
    BOOL __block hasTextAttachment = false;
    
    if (self.attributedText.length) {
        
        [self.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, [self.attributedText length])
                                        options:0
                                     usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             if ([value isKindOfClass:[NSTextAttachment class]]) {
                 NSTextAttachment *attachment = (NSTextAttachment *)value;
                 UIImage *image = nil;
                 if ([attachment image]) {
                     image = [attachment image];
                 }
                 else {
                     image = [attachment imageForBounds:[attachment bounds]
                                          textContainer:nil
                                         characterIndex:range.location];
                 }
                 
                 if (image) {
                     hasTextAttachment = true;
                     *stop = true;
                 }
                 
             }
         }];
    }
    return hasTextAttachment;
}

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder {
    
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    
    if ([placeHolderColor isEqual:_placeHolderColor]) {
        return;
    }
    
    _placeHolderColor = placeHolderColor;
    [self setNeedsDisplay];
}

#pragma mark - UITextView overrides

- (void)setText:(NSString *)text {
    
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)paste:(id)sender
{
    BOOL shouldPaste = true;
    
    if ([self.pasteDelegate respondsToSelector:@selector(placeHolderTextView:shouldPasteWithSender:)]) {
        shouldPaste = [self.pasteDelegate placeHolderTextView:self shouldPasteWithSender:sender];
    }
    
    if (shouldPaste)
    {
        [super paste:sender];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    if ([self.text length] == 0 && self.placeHolder && ![self hasTextAttachment]) {
        [self.placeHolderColor set];
        
        [self.placeHolder drawInRect:CGRectInset(rect, 7.0f, 5.0f)
                      withAttributes:[self placeholderTextAttributes]];
    }
}

#pragma mark - Notifications

- (void)addTextViewNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)removeTextViewNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)didReceiveTextViewNotification:(NSNotification *)notification {
    
    [self setNeedsDisplay];
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(__unused id)sender
{
    if  ([UIPasteboard generalPasteboard].image && action == @selector(paste:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
   
}
#pragma mark - Utilities

- (NSDictionary *)placeholderTextAttributes {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;
    
    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}

@end
