//
//  QBMEventResult.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

/** QBMEventResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get event. */

@interface QBMEventResult : Result {
    
}

/** An Event */
@property (nonatomic,readonly) QBMEvent *event;

@end
