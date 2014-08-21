//
//  QBChatHistoryMessageAnswer.h
//  Quickblox
//
//  Created by Igor Alefirenko on 29/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//


@interface QBChatHistoryMessageAnswer : XmlAnswer {
    QBChatHistoryMessage *message;
    QBChatAttachment *attachment;
    
    NSMutableDictionary *customParams;
    NSMutableArray *attachments;
}

@property (nonatomic, readonly) NSMutableArray *messages;

@end
