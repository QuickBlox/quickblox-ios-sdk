#import "CDMessage.h"
#import "CDAttachment.h"
#import "NSManagedObject+QMCDRecord.h"
#import "QMSLog.h"

@implementation CDMessage

- (QBChatMessage *)toQBChatMessage {
    
    QBChatMessage *message = [QBChatMessage alloc];
    
    message.ID = self.messageID;
    message.text = self.text;
    message.recipientID = self.recipientID.intValue;
    message.senderID = self.senderID.intValue;
    message.dateSent = self.dateSend;
    message.dialogID = self.dialogID;
    message.updatedAt = self.updateAt;
    message.createdAt = self.createAt;
    message.delayed = self.delayed.boolValue;
    message.customParameters = [[NSKeyedUnarchiver unarchiveObjectWithData:self.customParameters] mutableCopy];
    message.readIDs = [NSKeyedUnarchiver unarchiveObjectWithData:self.readIDs];
    message.deliveredIDs = [NSKeyedUnarchiver unarchiveObjectWithData:self.deliveredIDs];

    NSMutableArray<QBChatAttachment *> *attachments =
    [NSMutableArray arrayWithCapacity:self.attachments.count];
    
    for (CDAttachment *cdAttachment in self.attachments) {
        QBChatAttachment *attachment = [cdAttachment toQBChatAttachment];
        [attachments addObject:attachment];
    }

    message.attachments = [attachments copy];
    
    if (!self.changedValues.count) {
        [self.managedObjectContext refreshObject:self mergeChanges:NO];
    }
    else if (!self.isInserted){
        QMSLog(@"Cache > %@ > %@: %@", self.class, self.messageID ,self.changedValues);
    }
    return message;
}

- (void)updateWithQBChatMessage:(QBChatMessage *)message {
    
    self.messageID = message.ID;
    
    self.createAt = message.createdAt;
    self.updateAt = message.updatedAt;
    self.delayedValue = message.delayed;
    self.text = message.text;
    self.dateSend = message.dateSent;
    self.recipientIDValue = (int32_t)message.recipientID;
    self.senderID = @(message.senderID);
    self.dialogID = message.dialogID;
    
    self.customParameters = [NSKeyedArchiver archivedDataWithRootObject:message.customParameters];
    self.readIDs = [NSKeyedArchiver archivedDataWithRootObject:message.readIDs];
    self.deliveredIDs = [NSKeyedArchiver archivedDataWithRootObject:message.deliveredIDs];

    if (message.attachments.count > 0) {
        
        NSMutableSet *attachments = [NSMutableSet setWithCapacity:message.attachments.count];
        NSManagedObjectContext *context = [self managedObjectContext];

        for (QBChatAttachment *qbChatAttachment in message.attachments) {
            
            CDAttachment *attachment = [CDAttachment QM_createEntityInContext:context];
            [attachment updateWithQBChatAttachment:qbChatAttachment];
            [attachments addObject:attachment];
        }
        
        [self setAttachments:attachments];
    }
    else {
        message.attachments = @[];
    }
}

@end

@implementation NSArray(CDMessage)

- (NSArray<QBChatMessage *> *)toQBChatMessages {
    
    NSMutableArray<QBChatMessage *> *result =
    [NSMutableArray arrayWithCapacity:self.count];
    
    for (CDMessage *cache in self) {
        
        QBChatMessage *message = [cache toQBChatMessage];
        [result addObject:message];
    }
    
    return [result copy];
}

@end
