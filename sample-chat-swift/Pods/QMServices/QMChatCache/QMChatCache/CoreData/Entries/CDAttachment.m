#import "CDAttachment.h"

@implementation CDAttachment

- (QBChatAttachment *)toQBChatAttachment {
    
    QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
    attachment.ID = self.id;
    attachment.url = self.url;
    attachment.type = self.mimeType;
    
    return attachment;
}

- (void)updateWithQBChatAttachment:(QBChatAttachment *)attachment {
    
    self.id = attachment.ID;
    self.url = attachment.url;
    self.mimeType = attachment.type;
}

@end
