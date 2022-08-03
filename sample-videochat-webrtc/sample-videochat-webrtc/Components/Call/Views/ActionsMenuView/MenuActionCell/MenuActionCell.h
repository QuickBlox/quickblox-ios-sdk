//
//  MenuActionCell.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kMenuActionCellIdentifier = @"MenuActionCell";

@interface MenuActionCell : UITableViewCell
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

NS_ASSUME_NONNULL_END
