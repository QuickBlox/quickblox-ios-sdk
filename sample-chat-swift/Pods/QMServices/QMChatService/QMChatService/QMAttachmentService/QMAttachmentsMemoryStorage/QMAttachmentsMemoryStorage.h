//
//  QMAttachmentsMemoryStorage.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/25/17.
//
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import "QMMemoryStorageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMAttachmentsMemoryStorage : NSObject <QMMemoryStorageProtocol>

- (void)addAttachment:(QBChatAttachment *)attachment
         forMessageID:(NSString *)messageID;

- (nullable QBChatAttachment *)attachmentWithID:(NSString *)attachmentID
                                  fromMessageID:(NSString *)messageID;

- (void)updateAttachment:(QBChatAttachment *)attachment
            forMessageID:(NSString *)messageID;

- (void)deleteAttachment:(QBChatAttachment *)attachment
            forMessageID:(NSString *)messageID;

@end

NS_ASSUME_NONNULL_END
