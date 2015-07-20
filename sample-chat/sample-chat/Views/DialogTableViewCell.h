//
//  DialogTableViewCell.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *unreadContainerView;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dialogImageView;
@property (weak, nonatomic) IBOutlet UILabel *dialogNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageTextLabel;

@end
