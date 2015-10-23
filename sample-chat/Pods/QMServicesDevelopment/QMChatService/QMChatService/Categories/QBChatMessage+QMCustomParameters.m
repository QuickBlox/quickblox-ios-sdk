//
//  QBChatAbstractMessage+QMCustomParameters.h
//  QMServices
//
//  Created by Andrey Ivanov on 24.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QBChatMessage+QMCustomParameters.h"
#import <objc/runtime.h>

/*Message keys*/
NSString const *kQMCustomParameterSaveToHistory = @"save_to_history";
NSString const *kQMCustomParameterMessageType = @"notification_type";
NSString const *kQMCustomParameterChatMessageID = @"chat_message_id";
NSString const *kQMCustomParameterDateSent = @"date_sent";
NSString const *kQMCustomParameterChatMessageDeliveryStatus = @"message_delivery_status_read";
/*Dialogs keys*/
NSString const *kQMCustomParameterDialogID = @"dialog_id";
NSString const *kQMCustomParameterRoomJID = @"room_jid";
NSString const *kQMCustomParameterDialogRoomName = @"room_name";
NSString const *kQMCustomParameterDialogRoomPhoto = @"room_photo";
NSString const *kQMCustomParameterDialogRoomLastMessageDate = @"room_last_message_date";
NSString const *kQMCustomParameterDialogUpdatedDate = @"dialog_updated_date";
NSString const *kQMCustomParameterDialogType = @"type";
NSString const *kQMCustomParameterDialogOccupantsIDs = @"occupants_ids";
NSString const *kQMCustomParameterDialogDeletedID = @"deleted_id";
NSString const *kQMCustomParameterDialogRoomUpdatedDate = @"room_updated_date";

@interface QBChatMessage (Context)

@property (strong, nonatomic) NSMutableDictionary *context;
@property (strong, nonatomic) QBChatDialog *tDialog;

@end

@implementation QBChatMessage (QMCustomParameters)

/*Message params*/
@dynamic saveToHistory;
@dynamic messageType;
@dynamic chatMessageID;
@dynamic customDateSent;
@dynamic messageDeliveryStatus;
@dynamic dialog;
@dynamic attachmentStatus;

- (NSMutableDictionary *)context {
    
    if (!self.customParameters) {
        self.customParameters = [NSMutableDictionary dictionary];
    }
    
    return self.customParameters;
}

- (QBChatDialog *)dialog {
    
    if (!self.tDialog) {
        
        self.tDialog = [[QBChatDialog alloc] initWithDialogID:self.context[kQMCustomParameterDialogID]
                                                         type:[self.context[kQMCustomParameterDialogType] intValue]];
        //Grap custom parameters;
        self.tDialog.roomJID = self.context[kQMCustomParameterRoomJID];
		NSAssert(self.tDialog.type != 0, @"dialog type is undefined");
        self.tDialog.name = self.context[kQMCustomParameterDialogRoomName];
        self.tDialog.photo = self.context[kQMCustomParameterDialogRoomPhoto];
    
        NSString *lastMessageDateTimeInterval = self.context[kQMCustomParameterDialogRoomLastMessageDate];
        
        if (lastMessageDateTimeInterval) {
            self.tDialog.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:[lastMessageDateTimeInterval floatValue]];
        }
        
        NSString * strIDs = self.context[kQMCustomParameterDialogOccupantsIDs];
        
        NSArray *componets = [strIDs componentsSeparatedByString:@","];
        NSMutableArray *occupatnsIDs = [NSMutableArray arrayWithCapacity:componets.count];
        
        for (NSString *occupantID in componets) {
            
            [occupatnsIDs addObject:@(occupantID.integerValue)];
        }
        
        self.tDialog.occupantIDs = occupatnsIDs;
    }
    
    return self.tDialog;
}

- (QBChatDialog *)tDialog {
    
    return objc_getAssociatedObject(self, @selector(tDialog));
}

- (void)setTDialog:(QBChatDialog *)tDialog {
    
    objc_setAssociatedObject(self, @selector(tDialog), tDialog, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QMMessageAttachmentStatus)attachmentStatus {
    return [[self tAttachmentStatus] integerValue];
}

- (void)setAttachmentStatus:(QMMessageAttachmentStatus)attachmentStatus {
    [self setTAttachmentStatus:@(attachmentStatus)];
}

- (NSNumber *)tAttachmentStatus {
    return objc_getAssociatedObject(self, @selector(tAttachmentStatus));
}

- (void)setTAttachmentStatus:(NSNumber *)attachmentStatusNumber {
    objc_setAssociatedObject(self, @selector(tAttachmentStatus), attachmentStatusNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateCustomParametersWithDialog:(QBChatDialog *)dialog {
    
    self.tDialog = nil;
    
    self.context[kQMCustomParameterDialogID] = dialog.ID;
    self.context[kQMCustomParameterDialogType] = @(dialog.type);
	
	if (dialog.lastMessageDate != nil){
		NSTimeInterval lastMessageDateTimeInterval = [dialog.lastMessageDate timeIntervalSince1970];
		self.context[kQMCustomParameterDialogRoomLastMessageDate] = [@(lastMessageDateTimeInterval) stringValue];
	}
	
    if (dialog.type == QBChatDialogTypeGroup) {
		
		if (dialog.photo != nil) {
			self.context[kQMCustomParameterDialogRoomPhoto] = dialog.photo;
		}
		if (dialog.name != nil) {
			self.context[kQMCustomParameterDialogRoomName] = dialog.name;
		}
		if (dialog.roomJID != nil ){
			self.context[kQMCustomParameterRoomJID] = dialog.roomJID;
		}
		
        NSTimeInterval nowDateTimeInterval = [[NSDate date] timeIntervalSince1970];
        self.context[kQMCustomParameterDialogRoomUpdatedDate] = [@(nowDateTimeInterval) stringValue];
		
        NSString *strIDs = [dialog.occupantIDs componentsJoinedByString:@","];
        self.context[kQMCustomParameterDialogOccupantsIDs] = strIDs;
    }
}

- (void)setDialogOccupantsIDs:(NSArray *)dialogOccupantsIDs {
    
    NSString *strIDs = [dialogOccupantsIDs componentsJoinedByString:@","];
    self.context[kQMCustomParameterDialogOccupantsIDs] = strIDs;
}

- (NSArray *)dialogOccupantsIDs {
    
    NSString *strIDs = self.context[kQMCustomParameterDialogOccupantsIDs];
    
    NSArray *componets = [strIDs componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:componets.count];
    
    for (NSString *occupantID in componets) {
        
        [result addObject:@(occupantID.integerValue)];
    }
    
    return result;
}

#pragma mark - cParamChatMessageID

- (void)setChatMessageID:(NSString *)chatMessageID {
    
    self.context[kQMCustomParameterChatMessageID] = chatMessageID;
}

- (NSString *)chatMessageID {
    
    return self.context[kQMCustomParameterChatMessageID];
}

#pragma mark - dateSent

- (void)setCustomDateSent:(NSNumber *)dateSent {
    
    self.context[kQMCustomParameterDateSent] = dateSent;
}

- (NSNumber *)customDateSent {
    
    return self.context[kQMCustomParameterDateSent];
}

#pragma mark - cParamSaveToHistory

- (void)setSaveToHistory:(NSString *)saveToHistory {
    
    self.context[kQMCustomParameterSaveToHistory] = saveToHistory;
}

- (NSString *)saveToHistory {
    
    return self.context[kQMCustomParameterSaveToHistory];
}

#pragma mark - dialogDeletedID

- (void)setDialogDeletedID:(NSNumber *)dialogDeletedID {
    
    self.context[kQMCustomParameterDialogDeletedID] = dialogDeletedID;
}

- (NSNumber *)dialogDeletedID {
    
    return self.context[kQMCustomParameterDialogDeletedID];
}

#pragma mark - messageType

- (void)setMessageType:(QMMessageType)messageType {
    
    if (messageType != QMMessageTypeText) {

        self.context[kQMCustomParameterMessageType] = @(messageType);
    }
}

- (QMMessageType)messageType {
    
    return [self.context[kQMCustomParameterMessageType] integerValue];
}

- (BOOL)isNotificatonMessage {
    
    return self.messageType != QMMessageTypeText;
}

- (BOOL)isMediaMessage {
    
   return self.attachments.count > 0;
}

@end
