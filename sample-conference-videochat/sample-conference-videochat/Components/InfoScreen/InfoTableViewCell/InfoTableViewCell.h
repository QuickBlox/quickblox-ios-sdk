//
//  InfoTableViewCell.h
//  sample-conference-videochat
//
//  Created by Vladimir Nybozhinsky on 12/30/18.
//  Copyright © 2018 Quickblox. All rights reserved.
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
