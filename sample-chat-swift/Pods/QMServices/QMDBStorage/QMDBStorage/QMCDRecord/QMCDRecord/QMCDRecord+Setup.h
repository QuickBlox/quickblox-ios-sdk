//
//  QMCDRecord+Setup.h
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"

@class QMCDRecordStack;

@interface QMCDRecord (Setup)

+ (QMCDRecordStack *) setupSQLiteStack;
+ (QMCDRecordStack *) setupSQLiteStackWithStoreAtURL:(NSURL *)url;
+ (QMCDRecordStack *) setupSQLiteStackWithStoreNamed:(NSString *)storeName;

+ (QMCDRecordStack *) setupAutoMigratingStack;
+ (QMCDRecordStack *) setupAutoMigratingStackWithSQLiteStoreNamed:(NSString *)storeName;
+ (QMCDRecordStack *) setupAutoMigratingStackWithSQLiteStoreAtURL:(NSURL *)url;

+ (QMCDRecordStack *) setupManuallyMigratingStack;
+ (QMCDRecordStack *) setupManuallyMigratingStackWithSQLiteStoreNamed:(NSString *)storeName;
+ (QMCDRecordStack *) setupManuallyMigratingStackWithSQLiteStoreAtURL:(NSURL *)url;

+ (QMCDRecordStack *) setupClassicStack;
+ (QMCDRecordStack *) setupClassicStackWithSQLiteStoreNamed:(NSString *)storeName;
+ (QMCDRecordStack *) setupClassicStackWithSQLiteStoreAtURL:(NSURL *)storeURL;

+ (QMCDRecordStack *) setupiCloudStackWithLocalStoreNamed:(NSString *)localStore;

+ (QMCDRecordStack *) setupStackWithInMemoryStore;

@end
