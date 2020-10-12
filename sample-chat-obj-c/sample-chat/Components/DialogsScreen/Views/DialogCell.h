//
//  DialogCell.h
//  samplechat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DialogCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UIView *checkBoxView;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dialogLastMessage;
@property (weak, nonatomic) IBOutlet UILabel *dialogName;
@property (weak, nonatomic) IBOutlet UILabel *dialogAvatarLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessageCounterLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadMessageCounterHolder;
@end

NS_ASSUME_NONNULL_END
