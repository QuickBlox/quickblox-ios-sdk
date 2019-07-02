//
//  UserTableViewCell.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

- (void)setFullName:(NSString *)fullName;
- (void)setCheck:(BOOL)isCheck;
- (void)setUserImage:(UIImage *)image;

@end
