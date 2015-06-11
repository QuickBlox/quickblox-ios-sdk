//
//  QBChatMessageAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/31/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@class QBChatHistoryMessage;
@class QBChatAttachment;
@interface QBChatMessageAnswer : XmlAnswer{
    QBChatAttachment *attachment;
    
    NSMutableDictionary *customParams;
    NSMutableArray *attachments;
}

@property (nonatomic, readonly) QBChatHistoryMessage *message;

@end
