//
//  ChatDateCell.h
//  samplechat
//
//  Created by Injoit on 08.03.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ChatCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatDateCell : ChatCell
@property (weak, nonatomic) IBOutlet UIView *dateBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

NS_ASSUME_NONNULL_END
