//
//  Button.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionButton : UIButton
//MARK: - Properties
@property (strong, nonatomic) UIImageView *iconView;
@property (nonatomic, assign) BOOL pressed;
@property (nonatomic, assign) BOOL pushed;
@property (nonatomic, strong) NSString *selectedTitle;
@property (nonatomic, strong) NSString *unSelectedTitle;

@end
