//
//  QMCDRecordStack_Private.h
//  QMCDRecord
//
//  Created by Injoit on 9/15/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"

@interface QMCDRecordStack ()

- (NSPersistentStoreCoordinator *) createCoordinator;
- (NSPersistentStoreCoordinator *) createCoordinatorWithOptions:(NSDictionary *)options;

- (NSManagedObjectContext *) createConfinementContext;
- (void) loadStack;

@end
