//
//  QMChatCell.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCell.h"
#import "QMChatCellLayoutAttributes.h"
#import "TTTAttributedLabel.h"
#import "QMImageView.h"

@interface TTTAttributedLabel(PrivateAPI)
    - (TTTAttributedLabelLink *)linkAtPoint:(CGPoint)point;
@end

static NSMutableSet *_qmChatCellMenuActions = nil;

@interface QMChatCell() <QMImageViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet QMChatContainerView *containerView;
@property (weak, nonatomic) IBOutlet UIView *messageContainer;

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *textView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *topLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *bottomLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightInsetConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomLabelVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelTextViewVerticalSpaceConstraint;

@property (weak, nonatomic, readwrite) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation QMChatCell

#pragma mark - Class methods

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qmChatCellMenuActions = [NSMutableSet new];
    });
}

+ (UINib *)nib {
    
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    
    return NSStringFromClass([self class]);
}

+ (void)registerMenuAction:(SEL)action {
    
    [_qmChatCellMenuActions addObject:NSStringFromSelector(action)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarView.delegate = self;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
	
    self.messageContainerTopInsetConstraint.constant = 0;
    self.messageContainerLeftInsetConstraint.constant = 0;
    self.messageContainerBottomInsetConstraint.constant = 0;
    self.messageContainerRightInsetConstraint.constant = 0;
    
    self.avatarContainerViewWidthConstraint.constant = 0;
    self.avatarContainerViewHeightConstraint.constant = 0;
    
    self.topLabelHeightConstraint.constant = 0;
    self.bottomLabelHeightConstraint.constant = 0;
    
    self.topLabelTextViewVerticalSpaceConstraint.constant = 0;
    self.textViewBottomLabelVerticalSpaceConstraint.constant = 0;
    
#if Q_DEBUG_COLORS == 0
    self.backgroundColor = [UIColor clearColor];
    self.messageContainer.backgroundColor = [UIColor clearColor];
    self.topLabel.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.bottomLabel.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.avatarView.backgroundColor = [UIColor clearColor];
#endif
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    return layoutAttributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {

    [super applyLayoutAttributes:layoutAttributes];

    QMChatCellLayoutAttributes *customAttributes = (id)layoutAttributes;
    
    [self updateConstraint:self.avatarContainerViewHeightConstraint withConstant:customAttributes.avatarSize.height];
    [self updateConstraint:self.avatarContainerViewWidthConstraint withConstant:customAttributes.avatarSize.width];
    [self.avatarView layoutIfNeeded];

    [self updateConstraint:self.topLabelHeightConstraint withConstant:customAttributes.topLabelHeight];
    [self updateConstraint:self.bottomLabelHeightConstraint withConstant:customAttributes.bottomLabelHeight];
    
    [self updateConstraint:self.messageContainerTopInsetConstraint withConstant:customAttributes.containerInsets.top];
    [self updateConstraint:self.messageContainerLeftInsetConstraint withConstant:customAttributes.containerInsets.left];
    [self updateConstraint:self.messageContainerBottomInsetConstraint withConstant:customAttributes.containerInsets.bottom];
    [self updateConstraint:self.messageContainerRightInsetConstraint withConstant:customAttributes.containerInsets.right];
    
    [self updateConstraint:self.topLabelTextViewVerticalSpaceConstraint withConstant:customAttributes.spaceBetweenTopLabelAndTextView];
    [self updateConstraint:self.textViewBottomLabelVerticalSpaceConstraint withConstant:customAttributes.spaceBetweenTextViewAndBottomLabel];
	
    [self updateConstraint:self.containerWidthConstraint withConstant:customAttributes.containerSize.width];
	
    [self layoutIfNeeded];
}

- (void)updateConstraint:(NSLayoutConstraint *)constraint withConstant:(CGFloat)constant {

    if ((int)constraint.constant == (int)constant) {
        return;
    }
    
    constraint.constant = constant;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
		[self layoutIfNeeded];
        self.contentView.frame = bounds;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    self.containerView.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    self.containerView.highlighted = selected;
}


#pragma mark - Menu actions

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    if ([_qmChatCellMenuActions containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    if ([_qmChatCellMenuActions containsObject:NSStringFromSelector(anInvocation.selector)]) {
        
        id sender;
        [anInvocation getArgument:&sender atIndex:0];
        
        if ([self.delegate respondsToSelector:@selector(chatCell:didPerformAction:withSender:)]) {
            
            [self.delegate chatCell:self didPerformAction:anInvocation.selector withSender:sender];
        }
    }
    else {
        
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    if ([_qmChatCellMenuActions containsObject:NSStringFromSelector(aSelector)]) {
        
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

#pragma mark - Gesture recognizers

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    [self.delegate chatCellDidTapAvatar:self];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    
    CGPoint touchPt = [tap locationInView:self];
    UIView *touchView = [tap.view hitTest:touchPt withEvent:nil];
    
    if ([touchView isKindOfClass:[TTTAttributedLabel class]]) {
        
        TTTAttributedLabel *label = (TTTAttributedLabel *)touchView;
        CGPoint translatedPoint = [label convertPoint:touchPt fromView:tap.view];
        
        TTTAttributedLabelLink *labelLink = [label linkAtPoint:translatedPoint];
        
        if (labelLink.result.numberOfRanges > 0) {
            
            if ([self.delegate respondsToSelector:@selector(chatCell:didTapOnTextCheckingResult:)]) {
                
                [self.delegate chatCell:self didTapOnTextCheckingResult:labelLink.result];
            }
            
            return;
        }
    }
    
    if (CGRectContainsPoint(self.containerView.frame, touchPt)) {
        
        [self.delegate chatCellDidTapContainer:self];
    }
    else if ([self.delegate respondsToSelector:@selector(chatCell:didTapAtPosition:)]) {
        
        [self.delegate chatCell:self didTapAtPosition:touchPt];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGPoint touchPt = [touch locationInView:gestureRecognizer.view];
    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        if ([touch.view isKindOfClass:[TTTAttributedLabel class]]) {
            
            TTTAttributedLabel *label = (TTTAttributedLabel *)touch.view;
            CGPoint translatedPoint = [label convertPoint:touchPt fromView:gestureRecognizer.view];
            
            
            TTTAttributedLabelLink *labelLink = [label linkAtPoint:translatedPoint];
            
            if (labelLink.result.numberOfRanges > 0) {
                
                return NO;
            }
        }
        
        return CGRectContainsPoint(self.containerView.frame, touchPt);
    }
    
    return YES;
}

#pragma mark - Layout model

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = {

        .avatarSize = CGSizeMake(30, 30),
        .containerInsets = UIEdgeInsetsMake(4, 5, 4, 5),
        .containerSize = CGSizeZero,
        .topLabelHeight = 17,
        .bottomLabelHeight = 14,
        .maxWidthMarginSpace = 20
    };
    
    return defaultLayoutModel;
}

@end
