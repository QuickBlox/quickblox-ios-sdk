//
//  QBChatMessagePagedAnswer.h
//  Quickblox
//
//  Created by Igor Alefirenko on 29/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@class QBChatMessageAnswer;
@interface QBChatMessagePagedAnswer : XmlAnswer {
    QBChatMessageAnswer *messageAnswer;
}

@property (nonatomic, readonly) NSMutableArray *messages;

@end
