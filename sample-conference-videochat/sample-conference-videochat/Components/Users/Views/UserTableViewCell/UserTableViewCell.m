//
//  UserTableViewCell.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 03/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
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
