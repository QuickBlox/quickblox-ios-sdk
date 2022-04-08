//
//  ChatPrivateTitleView.h
//  sample-chat
//
//  Created by Injoit on 2/11/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatPrivateTitleView : UIStackView
- (void)setupPrivateChatTitleViewWithOpponentUser:(QBUUser *)opponentUser;
@end

NS_ASSUME_NONNULL_END
