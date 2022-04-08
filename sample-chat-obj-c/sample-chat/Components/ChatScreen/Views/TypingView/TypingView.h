//
//  TypingView.h
//  sample-chat
//
//  Created by Injoit on 2/11/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypingView : UIView
- (void)setupTypingViewWithOpponentUsersIDs:( NSSet * _Nullable )opponentUsersIDs;
@end

NS_ASSUME_NONNULL_END
