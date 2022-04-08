//
//  UserTableViewCell.h
//  sample-chat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kUserCellIdentifier = @"UserTableViewCell";

@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *checkBoxView;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
- (void)setupUserName:(NSString *)userName;
- (void)setupUserID:(NSUInteger)userID;
@end

NS_ASSUME_NONNULL_END
