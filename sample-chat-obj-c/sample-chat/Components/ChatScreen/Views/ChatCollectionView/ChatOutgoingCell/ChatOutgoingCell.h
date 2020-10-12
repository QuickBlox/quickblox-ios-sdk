//
//  ChatOutgoingCell.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Chat message cell typically used for your messages.
 */
@interface ChatOutgoingCell : ChatCell
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@end

NS_ASSUME_NONNULL_END
