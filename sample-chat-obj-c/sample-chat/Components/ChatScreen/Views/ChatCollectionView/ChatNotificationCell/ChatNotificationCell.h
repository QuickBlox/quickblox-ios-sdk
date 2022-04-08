//
//  ChatNotificationCell.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatNotificationCell : ChatCell
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@end

NS_ASSUME_NONNULL_END
