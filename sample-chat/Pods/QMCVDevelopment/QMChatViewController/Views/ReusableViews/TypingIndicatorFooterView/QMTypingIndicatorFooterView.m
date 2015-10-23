//
//  QMTypingIndicatorFooterView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMTypingIndicatorFooterView.h"

const CGFloat kQMTypingIndicatorFooterViewHeight = 46.0f;

@interface QMTypingIndicatorFooterView()

@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewRightHorizontalConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *typingIndicatorImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typingIndicatorImageViewRightHorizontalConstraint;

@end

@implementation QMTypingIndicatorFooterView

+ (UINib *)nib {
    
    return [UINib nibWithNibName:NSStringFromClass([QMTypingIndicatorFooterView class])
                          bundle:[NSBundle bundleForClass:[QMTypingIndicatorFooterView class]]];
}

+ (NSString *)footerReuseIdentifier {
    
    return NSStringFromClass([QMTypingIndicatorFooterView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    self.typingIndicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)dealloc
{
    _bubbleImageView = nil;
    _typingIndicatorImageView = nil;
}

#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.bubbleImageView.backgroundColor = backgroundColor;
}

#pragma mark - Typing indicator

- (void)configureWithEllipsisColor:(UIColor *)ellipsisColor
                messageBubbleColor:(UIColor *)messageBubbleColor
               shouldDisplayOnLeft:(BOOL)shouldDisplayOnLeft
                 forCollectionView:(UICollectionView *)collectionView
{
    NSParameterAssert(ellipsisColor != nil);
    NSParameterAssert(messageBubbleColor != nil);
    NSParameterAssert(collectionView != nil);
    
    [self setNeedsUpdateConstraints];
    
    self.bubbleImageView.backgroundColor = messageBubbleColor;
    self.typingIndicatorImageView.backgroundColor = ellipsisColor;
    self.typingIndicatorImageView.image = [UIImage imageNamed:@""];
}

@end

