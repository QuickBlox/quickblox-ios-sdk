//
//  InfoTableViewCell.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface InfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptInfoLabel;

- (void)applyInfo:(InfoModel*)model;

@end

NS_ASSUME_NONNULL_END
