//
//  ChatButtonFactory.h
//  sample-chat
//
//  Created by Injoit on 15.03.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatButtonFactory : NSObject
+ (UIButton *)accessoryButtonItem;
+ (UIButton *)sendButtonItem;
@end

NS_ASSUME_NONNULL_END
