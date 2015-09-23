#import "CDMessage.h"
#import "CDAttachment.h"
#import "NSManagedObject+QMCDRecord.h"

@interface CDMessage ()

@end

@implementation CDMessage

- (QBChatMessage *)toQBChatMessage {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    
    message.ID = self.messageID;
    message.text = self.text;
    message.recipientID = self.recipientID.intValue;
    message.senderID = self.senderID.intValue;
    message.dateSent = self.dateSend;
    message.dialogID = self.dialogID;
    message.customParameters = [[self objectsWithBinaryData:self.customParameters] mutableCopy];
    message.read = self.isRead.boolValue;
    message.updatedAt = self.updateAt;
    message.createdAt = self.createAt;
    message.delayed = self.delayed.boolValue;
    message.readIDs = [[self objectsWithBinaryData:self.readIDs] copy];
    message.deliveredIDs = [[self objectsWithBinaryData:self.deliveredIDs] copy];

    NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:self.attachments.count];
    
    for (CDAttachment *cdAttachment in self.attachments) {
        
        QBChatAttachment *attachment = [cdAttachment toQBChatAttachment];
        [attachments addObject:attachment];
    }
    
    message.attachments = attachments;
    
    return message;
}

- (void)updateWithQBChatMessage:(QBChatMessage *)message {
    
    self.messageID = message.ID;
    self.createAt = message.createdAt;
    self.updateAt = message.updatedAt;
    self.delayed = @(message.delayed);
    self.text = message.text;
    self.dateSend = message.dateSent;
    self.recipientID = @(message.recipientID);
    self.senderID = @(message.senderID);
    self.dialogID = message.dialogID;
    self.customParameters = [self binaryDataWithObject:message.customParameters];
    self.isRead = @(message.isRead);
    self.readIDs = [self binaryDataWithObject:message.readIDs];
    self.deliveredIDs = [self binaryDataWithObject:message.deliveredIDs];

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

- (NSData *)binaryDataWithObject:(id)object {
    
    NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:object];
    return binaryData;
}

- (id)objectsWithBinaryData:(NSData *)data {
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
