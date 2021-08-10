//
//  MenuActionCell.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuActionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

NS_ASSUME_NONNULL_END
