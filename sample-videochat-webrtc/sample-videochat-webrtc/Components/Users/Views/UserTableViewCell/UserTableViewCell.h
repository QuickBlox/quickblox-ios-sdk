//
//  UserTableViewCell.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kUserCellIdentifier = @"UserTableViewCell";

typedef void(^MuteButtonHandler)(BOOL isMuted);

@interface UserTableViewCell : UITableViewCell
@property (nonatomic, strong) MuteButtonHandler didPressMuteButton;

- (void)setupUserName:(NSString *)userName;
- (void)setupUserID:(NSUInteger)userID;
@end

NS_ASSUME_NONNULL_END
