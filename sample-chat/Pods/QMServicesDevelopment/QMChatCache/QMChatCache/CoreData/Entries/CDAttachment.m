#import "CDAttachment.h"

@implementation CDAttachment

- (QBChatAttachment *)toQBChatAttachment {
    
    QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
    
    attachment.name = self.name;
    attachment.ID = self.id;
    attachment.url = self.url;
    attachment.type = self.mimeType;

    NSDictionary *customParameters = [self objectsWithBinaryData:self.customParameters];
    [customParameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        attachment[key] = obj;
    }];
    return attachment;
}

- (void)updateWithQBChatAttachment:(QBChatAttachment *)attachment {
    
    self.name = attachment.name;
    self.id = attachment.ID;
    self.url = attachment.url;
    self.mimeType = attachment.type;

    self.customParameters = [self binaryDataWithObject:attachment.customParameters];
}

- (NSData *)binaryDataWithObject:(id)object {
    
    NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:object];
    return binaryData;
}

- (id)objectsWithBinaryData:(NSData *)data {
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
