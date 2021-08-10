//
//  ChatCallIncomingCell.h
//  sample-conference-videochat
//
//  Created by Injoit on 25.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "ChatCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatCallIncomingCell : ChatCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *streamLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (nonatomic, strong) CompletionCallActionBlock didPressJoinButton;
@end

NS_ASSUME_NONNULL_END
