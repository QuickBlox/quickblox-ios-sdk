//
//  ThreadedSQLiteQMCDRecordStack.h
//  QMCDRecord
//
//  Created by Injoit on 9/15/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "SQLiteQMCDRecordStack.h"

@interface SQLiteWithSavingContextQMCDRecordStack : SQLiteQMCDRecordStack

@property (nonatomic, strong, readonly) NSManagedObjectContext *savingContext;

@end
