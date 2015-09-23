//
//  DualContextDualCoordinatorQMCDRecordStack.h
//  QMCDRecord
//
//  Created by Injoit on 10/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "ClassicSQLiteQMCDRecordStack.h"

@interface ClassicWithBackgroundCoordinatorSQLiteQMCDRecordStack : ClassicSQLiteQMCDRecordStack

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *backgroundCoordinator;

@end
