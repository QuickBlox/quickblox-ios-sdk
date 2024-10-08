//
//  UserTableViewCell.h
//  sample-conference-videochat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MuteButtonHandler)(BOOL isMuted);

@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userAvatarLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *checkBoxView;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) UIColor *userColor;
@property (nonatomic, strong) MuteButtonHandler didPressMuteButton;

@end

NS_ASSUME_NONNULL_END
