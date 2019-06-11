//
//  UserTableViewCell.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CornerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;
@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UILabel *userDescriptionLabel;


@end

NS_ASSUME_NONNULL_END
