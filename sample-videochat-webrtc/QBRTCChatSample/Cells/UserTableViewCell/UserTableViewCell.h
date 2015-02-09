//
//  UserTableViewCell.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *userDescription;

- (void)setColorMarkerText:(NSString *)text andColor:(UIColor *)color;

@end
