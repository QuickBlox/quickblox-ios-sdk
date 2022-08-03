//
//  UserTagView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 03.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectUserViewCancelCompletion)(NSUInteger ID);

@interface SelectedUsersView : UIView
@property (strong, nonatomic) SelectUserViewCancelCompletion onSelectedUserViewCancelTapped;

- (void)addViewWithUserID:(NSUInteger)userID userName:(NSString *)userName;
- (void)removeViewWithUserID:(NSUInteger)userID;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
