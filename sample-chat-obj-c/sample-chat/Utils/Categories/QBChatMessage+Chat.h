//
//  QBChatMessage+Chat.h
//  sample-chat
//
//  Created by Injoit on 15.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBChatMessage (Chat)
@property (assign, nonatomic) BOOL isDateDividerMessage;
@property (assign, nonatomic) BOOL isNotificationMessageTypeCreate;
@property (assign, nonatomic) BOOL isNotificationMessageTypeAdding;
@property (assign, nonatomic) BOOL isNotificationMessageTypeLeave;

- (BOOL)isAttachmentMessage;
- (BOOL)isNotificationMessage;
- (NSAttributedString *)messageText;
- (CGSize)estimateFrameWithConstraintsSize:(CGSize)constraintsSize;
- (NSAttributedString *)topLabelText;
- (NSAttributedString *)timeLabelText;
- (NSAttributedString *)forwardedText;
- (BOOL)isViewedBy;
- (BOOL)isDeliveredTo;
- (UIImage *)statusImage;
@end

NS_ASSUME_NONNULL_END
