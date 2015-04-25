//
//  QBDialogsPagedResult.h
//  Quickblox
//
//  Created by Igor Alefirenko on 28/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBResult.h"
/** QBDialogsPagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to the user after he made ​​the request for get chat dialogs. */

@interface QBDialogsPagedResult : QBResult

/** An array of QBChatDialog objects */
@property (nonatomic, readonly) NSArray *dialogs;

/** A set of all dialogs users IDs */
@property (nonatomic, readonly) NSSet *dialogsUsersIDs;

@end
