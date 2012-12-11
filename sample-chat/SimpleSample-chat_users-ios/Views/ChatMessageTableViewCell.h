//
//  ChatMessageTableViewCell.h
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/21/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents chat message table view cell 
//

#import <UIKit/UIKit.h>

@interface ChatMessageTableViewCell : UITableViewCell

@property (nonatomic, retain) UITextView  *message;
@property (nonatomic, retain) UILabel     *date;
@property (nonatomic, retain) UIImageView *backgroundImageView;

@end
