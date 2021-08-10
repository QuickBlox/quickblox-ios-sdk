//
//  DialogTableViewCell.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *unreadContainerView;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dialogImageView;
@property (weak, nonatomic) IBOutlet UILabel *dialogNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageTextLabel;

@end
