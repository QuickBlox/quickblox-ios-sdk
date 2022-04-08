//
//  QBChatMessage+Chat.m
//  sample-chat
//
//  Created by Injoit on 15.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "QBChatMessage+Chat.h"
#import "Profile.h"
#import "ChatManager.h"
#import <Foundation/Foundation.h>

NSString const *kQBDateDividerCustomParameterKey = @"kQBDateDividerCustomParameterKey";
NSString const *kQBNotificationTypeKey = @"notification_type";
typedef NS_ENUM(NSUInteger, CustomParameter) {
    CustomParameterCreate = 1,
    CustomParameterAdding = 2,
    CustomParameterLeave = 3
};

@implementation QBChatMessage (Chat)

- (NSMutableDictionary *)context {
    if (!self.customParameters) {
        self.customParameters = [NSMutableDictionary dictionary];
    }
    return self.customParameters;
}

- (void)setIsDateDividerMessage:(BOOL)isDateDividerMessage {
    self.context[kQBDateDividerCustomParameterKey] = @(isDateDividerMessage);
}

- (BOOL)isDateDividerMessage {
    return [self.context[kQBDateDividerCustomParameterKey] boolValue];
}

- (BOOL)isNotificationMessage {
    return self.context[kQBNotificationTypeKey] != nil;
}

- (BOOL)isAttachmentMessage {
    return self.attachments.count > 0;
}

- (void)setIsNotificationMessageTypeCreate:(BOOL)isNotificationMessageTypeCreate {
    if (isNotificationMessageTypeCreate == YES) {
        self.context[kQBNotificationTypeKey] = @(CustomParameterCreate);
    }
}

- (BOOL)isNotificationMessageTypeCreate {
    if (self.isNotificationMessage == NO) {
        return NO;
    }
    return [self.context[kQBNotificationTypeKey] integerValue] == CustomParameterCreate;
}

- (void)setIsNotificationMessageTypeAdding:(BOOL)isNotificationMessageTypeAdding {
    if (isNotificationMessageTypeAdding == YES) {
        self.context[kQBNotificationTypeKey] = @(CustomParameterAdding);
    }
}

- (BOOL)isNotificationMessageTypeAdding {
    if (self.isNotificationMessage == NO) {
        return NO;
    }
    return [self.context[kQBNotificationTypeKey] integerValue] == CustomParameterAdding;
}

- (void)setIsNotificationMessageTypeLeave:(BOOL)isNotificationMessageTypeLeave {
    if (isNotificationMessageTypeLeave == YES) {
        self.context[kQBNotificationTypeKey] = @(CustomParameterLeave);
    }
}

- (BOOL)isNotificationMessageTypeLeave {
    if (self.isNotificationMessage == NO) {
        return NO;
    }
    return [self.context[kQBNotificationTypeKey] integerValue] == CustomParameterLeave;
}

#pragma mark - Strings builder
- (NSAttributedString *)messageText {
    if (!self.text) {
        return [[NSAttributedString alloc] initWithString:@"@"];
    }
    Profile *profile = [[Profile alloc] init];
    NSUInteger currentUserID = profile.ID;
    UIColor *textColor = [self senderID] == currentUserID ? [UIColor whiteColor] : [UIColor blackColor];
    if (self.isNotificationMessage || self.isDateDividerMessage) {
        textColor =  [UIColor blackColor];
    }
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font};
    if (self.customParameters[@"origin_sender_name"] != nil) {
        NSMutableAttributedString *textForwarded = [self forwardedText].mutableCopy;
        [textForwarded appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.text
                                                                                     attributes:attributes]];
        return textForwarded;
    }
    return [[NSMutableAttributedString alloc] initWithString:self.text
                                                  attributes:attributes];
}

- (CGSize)estimateFrameWithConstraintsSize:(CGSize)constraintsSize {
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect boundingRect = [[self messageText].string boundingRectWithSize:constraintsSize options:options attributes:attributes context:nil];
    CGSize size = CGSizeMake(boundingRect.size.width, boundingRect.size.height);
    return size;
}

- (NSAttributedString *)forwardedText {
    Profile *profile = [[Profile alloc] init];
    NSUInteger currentUserID = profile.ID;
    NSString *originForwardedName = self.context[@"origin_sender_name"];
    if (!originForwardedName) {
        return [[NSAttributedString alloc] initWithString:@"@"];
    }
    UIColor *forwardedColor = self.senderID == currentUserID ? [UIColor.whiteColor colorWithAlphaComponent:0.6f] : [UIColor colorWithRed:0.41f green:0.48f blue:0.59f alpha:1.0f];
    if (self.isAttachmentMessage == YES) {
        forwardedColor = [UIColor colorWithRed:0.41f green:0.48f blue:0.59f alpha:1.0f];
    }
    UIFont *fontForwarded = [UIFont systemFontOfSize:13.0f weight:UIFontWeightLight];
    UIFont *fontForwardedName = [UIFont systemFontOfSize:13.0f weight:UIFontWeightSemibold];
    NSDictionary *attributesForwarded = @{ NSForegroundColorAttributeName: forwardedColor,
                                           NSFontAttributeName: fontForwarded};
    NSDictionary *attributesForwardedName = @{ NSForegroundColorAttributeName: forwardedColor,
                                               NSFontAttributeName: fontForwardedName};
    NSMutableAttributedString *textForwarded = [[NSMutableAttributedString alloc] initWithString:@"Forwarded from " attributes: attributesForwarded];
    NSString *forwardedNameString = [NSString stringWithFormat:@"%@\n", originForwardedName];
    NSMutableAttributedString *forwardedName = [[NSMutableAttributedString alloc] initWithString:forwardedNameString attributes: attributesForwardedName];
    [textForwarded appendAttributedString:forwardedName];
    return textForwarded;
}

- (NSAttributedString *)topLabelText {
    UIColor *textColor = [UIColor colorWithRed:0.43f green:0.48f blue:0.57f alpha:1.0f];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    UIFont *font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightSemibold];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    NSString *topLabelString = @"";
    Profile *profile = [[Profile alloc] init];
    NSUInteger currentUserID = profile.ID;
    if (self.senderID == currentUserID) {
        topLabelString = @"You";
    } else {
        NSString *senderFullName = [ChatManager.instance.storage userWithID: self.senderID].fullName;
        NSString *senderID = [NSString stringWithFormat:@"@%lu", (unsigned long)self.senderID];
        topLabelString = senderFullName ? senderFullName : senderID;
    }
    
    return [[NSMutableAttributedString alloc] initWithString:topLabelString attributes:attributes];;
}

- (NSAttributedString *)timeLabelText {
    UIColor *textColor = [UIColor colorWithRed:0.43f green:0.48f blue:0.57f alpha:1.0f];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightRegular];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatter.dateFormat = @"HH:mm";
    NSString *text = [formatter stringFromDate:self.dateSent];
    
    return [[NSMutableAttributedString alloc] initWithString:text
                                                  attributes:attributes];
}

- (BOOL)isViewedBy {
    Profile *profile = [[Profile alloc] init];
    NSUInteger currentUserID = profile.ID;
    NSMutableArray* readIDs = [self.readIDs mutableCopy];
    [readIDs removeObject:@(currentUserID)];
    return readIDs.count > 0;
}

- (BOOL)isDeliveredTo {
    Profile *profile = [[Profile alloc] init];
    NSUInteger currentUserID = profile.ID;
    NSMutableArray* deliveredIDs = [self.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:@(currentUserID)];
    return deliveredIDs.count > 0;
}

- (UIImage *)statusImage {
    if (self.isViewedBy) {
        UIColor *readColor = [UIColor colorWithRed:0.22 green:0.47 blue:0.99f alpha:1.0f];
        return [[UIImage imageNamed:@"delivered"] imageWithTintColor:readColor];
    } else if (self.isDeliveredTo) {
        return [UIImage imageNamed:@"delivered"];
    }
    return [UIImage imageNamed:@"sent"];
}

@end
