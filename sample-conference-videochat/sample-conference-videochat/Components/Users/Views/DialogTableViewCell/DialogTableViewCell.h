//
//  DialogTableViewCell.h
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DialogTableViewCell;

@protocol DialogTableViewCellDelegate <NSObject>

- (void)dialogCellDidListenerButton:(DialogTableViewCell *)dialogCell;
- (void)dialogCellDidAudioButton:(DialogTableViewCell *)dialogCell;
- (void)dialogCellDidVideoButton:(DialogTableViewCell *)dialogCell;

@end

@interface DialogTableViewCell : UITableViewCell

@property (weak, nonatomic) id<DialogTableViewCellDelegate> delegate;

- (void)setTitle:(NSString *)title;

@end
