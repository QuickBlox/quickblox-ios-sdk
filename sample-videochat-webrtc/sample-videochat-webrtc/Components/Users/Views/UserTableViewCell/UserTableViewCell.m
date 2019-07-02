//
//  UserTableViewCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UserTableViewCell.h"
#import "CheckView.h"

@interface UserTableViewCell()

@property (weak, nonatomic) IBOutlet CheckView *checkView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end

@implementation UserTableViewCell

#pragma mark - Setters

- (void)setFullName:(NSString *)fullName {
    
    self.fullNameLabel.text = fullName;
}

- (void)setCheck:(BOOL)isCheck {
    
    self.checkView.check = isCheck;
}

- (void)setUserImage:(UIImage *)image {
    
    self.userImageView.image = image;
}

@end
