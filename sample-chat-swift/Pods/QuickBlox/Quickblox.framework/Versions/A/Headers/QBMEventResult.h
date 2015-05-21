//
//  QBMEventResult.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import "QBResult.h"

@class QBMEvent;

/** QBMEventResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get event. */

@interface QBMEventResult : QBResult{
    
}

/** An Event */
@property (nonatomic,readonly) QBMEvent *event;

@end
