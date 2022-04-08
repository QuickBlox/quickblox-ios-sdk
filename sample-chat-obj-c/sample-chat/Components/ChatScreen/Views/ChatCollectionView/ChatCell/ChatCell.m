//
//  ChatCell.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatCell.h"
#import "ChatCellLayoutAttributes.h"
#import "ChatResources.h"
#import "UIView+Chat.h"

static NSMutableSet *_chatCellMenuActions = nil;

@interface ChatCell() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *avatarLabel;
@property (weak, nonatomic) IBOutlet ChatContainerView *containerView;
@property (weak, nonatomic) IBOutlet UIView *messageContainer;
@property (weak, nonatomic) IBOutlet UIView *previewContainer;

@property (weak, nonatomic) IBOutlet UILabel *textView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightInsetConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomLabelVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelTextViewVerticalSpaceConstraint;

@property (weak, nonatomic, readwrite) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ChatCell

//MARK: - Class methods
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatCellMenuActions = [NSMutableSet new];
    });
}

+ (void)registerForReuseInView:(id)dataView {
    
    NSString *cellIdentifier = [self cellReuseIdentifier];
    NSParameterAssert(cellIdentifier);
    
    UINib *nib = [self nib];
    NSParameterAssert(nib);
    
    if ([dataView isKindOfClass:[UITableView class]]) {
        
        [(UITableView *)dataView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    else if ([dataView isKindOfClass:[UICollectionView class]]) {
        
        [(UICollectionView *)dataView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    }
    else {
        NSAssert(NO, @"Trying to register cell for unsupported dataView");
    }
}

+ (UINib *)nib {
    return [ChatResources nibWithNibName:NSStringFromClass([self class])];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (void)registerMenuAction:(SEL)action {
    [_chatCellMenuActions addObject:NSStringFromSelector(action)];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.contentView.opaque = YES;
    _messageContainerTopInsetConstraint.constant = 0;
    _messageContainerLeftInsetConstraint.constant = 0;
    _messageContainerBottomInsetConstraint.constant = 0;
    _messageContainerRightInsetConstraint.constant = 0;
    
    _avatarContainerViewWidthConstraint.constant = 0;
    _avatarContainerViewHeightConstraint.constant = 0;
    
    _topLabelHeightConstraint.constant = 0;
    
    _topLabelTextViewVerticalSpaceConstraint.constant = 0;
    _textViewBottomLabelVerticalSpaceConstraint.constant = 0;
    
    if (self.avatarLabel) {
        [self.avatarLabel setRoundViewWithCornerRadius:20.0f];
    }
    if (self.avatarView) {
        self.avatarView.backgroundColor = UIColor.clearColor;
    }
    
#if Q_DEBUG_COLORS == 0
    self.backgroundColor = [UIColor clearColor];
    self.messageContainer.backgroundColor = [UIColor clearColor];
    self.topLabel.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.bottomLabel.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.previewContainer.backgroundColor = [UIColor clearColor];

#endif
    
    [self.layer setDrawsAsynchronously:YES];
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarLabel.text = @"";
    self.avatarView.image = UIImage.new;
    self.topLabel.text = @"";
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    return layoutAttributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    ChatCellLayoutAttributes *customAttributes = (id)layoutAttributes;
    
    [self updateConstraint:self.avatarContainerViewHeightConstraint
              withConstant:customAttributes.avatarSize.height];
    
    [self updateConstraint:self.avatarContainerViewWidthConstraint
              withConstant:customAttributes.avatarSize.width];
    
    [self updateConstraint:self.topLabelHeightConstraint
              withConstant:customAttributes.topLabelHeight];
    
    [self updateConstraint:self.messageContainerTopInsetConstraint
              withConstant:customAttributes.containerInsets.top];
    
    [self updateConstraint:self.messageContainerLeftInsetConstraint
              withConstant:customAttributes.containerInsets.left];
    
    [self updateConstraint:self.messageContainerBottomInsetConstraint
              withConstant:customAttributes.containerInsets.bottom];
    
    [self updateConstraint:self.messageContainerRightInsetConstraint
              withConstant:customAttributes.containerInsets.right];
    
    [self updateConstraint:self.topLabelTextViewVerticalSpaceConstraint
              withConstant:customAttributes.spaceBetweenTopLabelAndTextView];
    
    [self updateConstraint:self.textViewBottomLabelVerticalSpaceConstraint
              withConstant:customAttributes.spaceBetweenTextViewAndBottomLabel];
    
    [self updateConstraint:self.containerWidthConstraint
              withConstant:customAttributes.containerSize.width];
    
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

//MARK: - Menu actions

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_chatCellMenuActions containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    if ([_chatCellMenuActions containsObject:NSStringFromSelector(anInvocation.selector)]) {
        
        __unsafe_unretained id sender;
        [anInvocation getArgument:&sender atIndex:0];
        
        if ([self.delegate respondsToSelector:@selector(chatCell:didPerformAction:withSender:)]) {
            
            [self.delegate chatCell:self didPerformAction:anInvocation.selector withSender:sender];
        }
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([_chatCellMenuActions containsObject:NSStringFromSelector(aSelector)]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

//MARK: - Gesture recognizers
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    
    CGPoint touchPt = [tap locationInView:self];
    
    if (CGRectContainsPoint(self.containerView.frame, touchPt)) {
        [self.delegate chatCellDidTapContainer:self];
    } else if ([self.delegate respondsToSelector:@selector(chatCell:didTapAtPosition:)]) {
        [self.delegate chatCell:self didTapAtPosition:touchPt];
    }
}

//MARK: - Layout model

+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = {
        
        .avatarSize = CGSizeZero,
        .containerInsets = UIEdgeInsetsMake(4, 0, 4, 5),
        .containerSize = CGSizeZero,
        .topLabelHeight = 15,
        .timeLabelHeight = 15,
        .maxWidthMarginSpace = 20,
        .maxWidth = 0
    };
    
    return defaultLayoutModel;
}

@end

