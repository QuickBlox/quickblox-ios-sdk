//
//  BaseSettingsCell.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseItemModel.h"

@protocol SettingsCellDelegate;

@interface BaseSettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) BaseItemModel *model;

@property (weak, nonatomic) id <SettingsCellDelegate> delegate;

+ (NSString *)identifier;
+ (UINib *)nib;

@end

@protocol SettingsCellDelegate <NSObject>

- (void)cell:(BaseSettingsCell *)cell didChageModel:(BaseItemModel *)model;

@end
