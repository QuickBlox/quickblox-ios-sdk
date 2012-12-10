//
//  CustomTableViewCellCell.h
//  SimpleSample-chat_users-ios
//
//  Created by Alexey on 07.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCellCell : UITableViewCell
{
    UILabel* user;
    UILabel* status;
    UILabel* lat;
    UILabel* lon;
}

@property (nonatomic, retain) IBOutlet UILabel* user;
@property (nonatomic, retain) IBOutlet UILabel* status;
@property (nonatomic, retain) IBOutlet UILabel* lat;
@property (nonatomic, retain) IBOutlet UILabel* lon;

@end
