//
//  UserTagView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 03.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "SelectedUsersView.h"
#import "UserTagView.h"

const CGFloat paddingLeft = 10.0f;
const CGFloat spaceBetween = 2.0f;
const CGFloat heightView = 24.0f;

@interface SelectedUsersView()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *maxUsersLabel;
//MARK: - Properties
@property (strong, nonatomic) NSMutableArray<UserTagView *> *selectedViews;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@end

@implementation SelectedUsersView
//MARK: - Life Cycle
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.selectedViews = @[].mutableCopy;
    }
    return self;
}

//MARK: - Public Methods
- (void)addViewWithUserID:(NSUInteger)userID userName:(NSString *)userName {
    UserTagView *selectedUserView = [[NSBundle mainBundle] loadNibNamed:@"UserTagView"
                                                                  owner:nil
                                                                options:nil].firstObject;
    selectedUserView.name = userName;
    selectedUserView.userID = @(userID);
    [self addSubview:selectedUserView];
    [self.selectedViews addObject:selectedUserView];
    self.maxUsersLabel.hidden = YES;
    [self setupViews];
    
    __weak __typeof(self)weakSelf = self;
    [selectedUserView setOnCancelTapped:^(NSUInteger userID) {
        [weakSelf removeViewWithUserID:userID];
        if (weakSelf.onSelectedUserViewCancelTapped) {
            weakSelf.onSelectedUserViewCancelTapped(userID);
        }
        [weakSelf removeViewWithUserID:userID];
    }];
}

- (void)removeViewWithUserID:(NSUInteger)userID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@", @(userID)];
    UserTagView *selectedUserView = [self.selectedViews filteredArrayUsingPredicate:predicate].firstObject;
    if (!selectedUserView) {
        return;
    }
    NSPredicate *removePredicate = [NSPredicate predicateWithFormat:@"userID != %@", @(userID)];
    self.selectedViews = [self.selectedViews.copy filteredArrayUsingPredicate:removePredicate].mutableCopy;
    
    [selectedUserView removeFromSuperview];
    if (self.selectedViews.count == 0) {
        self.maxUsersLabel.hidden = NO;
        return;
    }
    self.maxUsersLabel.hidden = YES;
    for (UserTagView *view in self.selectedViews) {
        [view removeFromSuperview];
        [self addSubview:view];
    }
    [self setupViews];
}

- (void)clear {
    for (UserTagView *view in self.selectedViews) {
        [view removeFromSuperview];
    }
    self.selectedViews = @[].mutableCopy;
    self.maxUsersLabel.hidden = NO;
}

//MARK - Setup
- (void)setupViews {
    UserTagView *previousView = nil;
    CGFloat viewsWidth = 0.0f;
    NSUInteger spaceCount = 0;
    
    for (int i = 0; i < self.selectedViews.count; i++) {
        UserTagView *selectedUserView = self.selectedViews[i];
        selectedUserView.translatesAutoresizingMaskIntoConstraints = NO;
        [selectedUserView.heightAnchor constraintEqualToConstant:heightView].active = YES;
        CGFloat selectedUserViewWidth = selectedUserView.nameLabel.intrinsicContentSize.width + 37.0f;
        [selectedUserView.widthAnchor constraintEqualToConstant:selectedUserViewWidth].active = YES;
        if (previousView) {
            CGFloat allwidth = paddingLeft + (spaceBetween * spaceCount) + viewsWidth + selectedUserViewWidth;
            if (self.bounds.size.width > allwidth) {
                spaceCount = spaceCount + 1;
                [selectedUserView.leftAnchor constraintEqualToAnchor:previousView.rightAnchor constant:spaceBetween].active = YES;
                [selectedUserView.topAnchor constraintEqualToAnchor:previousView.topAnchor].active = YES;
            } else {
                self.topConstraint.constant = 3.0f;
                spaceCount = 0;
                viewsWidth = 0.0f;
                [selectedUserView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:paddingLeft].active = YES;
                [selectedUserView.topAnchor constraintEqualToAnchor:previousView.bottomAnchor constant:3.0f].active = YES;
            }
        } else {
            spaceCount = 1;
            self.topConstraint = [selectedUserView.topAnchor constraintEqualToAnchor:self.topAnchor constant:18.0f];
            self.topConstraint.active = YES;
            [selectedUserView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:paddingLeft].active = YES;
        }
        previousView = selectedUserView;
        viewsWidth = viewsWidth + selectedUserViewWidth;
    }
}

@end
