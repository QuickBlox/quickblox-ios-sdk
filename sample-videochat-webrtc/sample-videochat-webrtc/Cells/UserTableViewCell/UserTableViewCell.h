//
//  UserTableViewCell.h
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CornerView;

@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UILabel *userDescriptionLabel;
@property (strong, nonatomic) NSString *userDescription;

- (void)setMarkerColor:(UIColor *)color;
- (void)setMarkerText:(NSString *)text;

@end
