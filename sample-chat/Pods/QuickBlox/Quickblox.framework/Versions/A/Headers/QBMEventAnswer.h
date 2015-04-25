//
//  QBMEventAnswer.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import "EntityAnswer.h"

@class QBMEvent;

@interface QBMEventAnswer : EntityAnswer {
@protected
    QBMEvent *event;
}

@property (nonatomic,readonly) QBMEvent *event;

@end
