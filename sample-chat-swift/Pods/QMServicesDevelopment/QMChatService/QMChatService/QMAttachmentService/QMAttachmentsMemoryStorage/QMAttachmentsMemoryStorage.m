//
//  QMAttachmentsMemoryStorage.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/25/17.
//
//

#import "QMAttachmentsMemoryStorage.h"

@interface QMAttachmentsMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *attachmentsStorage;

@end

@implementation QMAttachmentsMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _attachmentsStorage = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addAttachment:(QBChatAttachment *)attachment
         forMessageID:(NSString *)messageID {

    NSMutableOrderedSet *datasource = [self dataSourceWithMessageID:messageID];
    
    NSUInteger indexOfMessage = [datasource indexOfObject:attachment];
    
    if (indexOfMessage != NSNotFound) {
        
        [datasource replaceObjectAtIndex:indexOfMessage withObject:attachment];
        
    }
    else {
        
        [datasource addObject:attachment];
    }
}

- (void)updateAttachment:(QBChatAttachment *)attachment
            forMessageID:(NSString *)messageID {
    
    [self addAttachment:attachment
           forMessageID:messageID];
}

- (void)deleteAttachment:(QBChatAttachment *)attachment
            forMessageID:(NSString *)messageID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithMessageID:messageID];
    [datasource removeObject:attachment];
}


- (QBChatAttachment *)attachmentWithID:(NSString *)atatchmentID
                         fromMessageID:(NSString *)messageID {
    
    NSParameterAssert(atatchmentID != nil);
    NSParameterAssert(messageID != nil);
    
    NSMutableOrderedSet *attachments = [self dataSourceWithMessageID:messageID];
    
    for (QBChatAttachment *attachment in attachments) {
        
        if ([attachment.ID isEqualToString:atatchmentID]) {
            
            return attachment;
        }
    }
    
    return nil;
}

#pragma mark - QMMemeoryStorageProtocol

- (void)free {
    
    [self.attachmentsStorage removeAllObjects];
}

- (NSMutableOrderedSet *)dataSourceWithMessageID:(NSString *)messageID {
    
    NSMutableOrderedSet *attachments = self.attachmentsStorage[messageID];
    
    if (!attachments) {
        attachments = [NSMutableOrderedSet orderedSet];
        self.attachmentsStorage[messageID] = attachments;
    }
    
    return attachments;
}

@end
