//
//  ChatButtonFactory.m
//  sample-chat
//
//  Created by Injoit on 15.03.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "ChatButtonFactory.h"
#import "ChatResources.h"
#import "UIColor+Chat.h"

@implementation ChatButtonFactory
+ (UIButton *)accessoryButtonItem {
    UIImage *accessoryImage = [ChatResources imageNamed:@"attachment_ic"];
    UIImage *normalImage = [accessoryImage imageWithTintColor:UIColor.appColor];
    UIImage *highlightedImage = [accessoryImage imageWithTintColor:UIColor.appColor];
    UIButton *accessoryButton =
    [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:normalImage forState:UIControlStateNormal];
    [accessoryButton setImage:highlightedImage forState:UIControlStateHighlighted];
    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];
    accessoryButton.tintColor = UIColor.appColor;
    return accessoryButton;
}

+ (UIButton *)sendButtonItem {
    UIImage *accessoryImage = [ChatResources imageNamed:@"send"];
    UIImage *normalImage = [accessoryImage imageWithTintColor:UIColor.appColor];
    UIImage *highlightedImage = [accessoryImage imageWithTintColor:UIColor.appColor];
    UIButton *sendButton =
    [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 28.0f)];
    [sendButton setImage:normalImage forState:UIControlStateNormal];
    [sendButton setImage:highlightedImage forState:UIControlStateHighlighted];
    sendButton.contentMode = UIViewContentModeScaleAspectFit;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = UIColor.appColor;
    return sendButton;
}
@end
