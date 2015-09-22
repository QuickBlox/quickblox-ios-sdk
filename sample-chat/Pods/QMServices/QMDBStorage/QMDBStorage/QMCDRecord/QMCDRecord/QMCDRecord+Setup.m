//
//  QMCDRecord+Setup.m
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord+Setup.h"
#import "NSManagedObject+QMCDRecord.h"
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "SQLiteQMCDRecordStack.h"
#import "AutoMigratingQMCDRecordStack.h"
#import "ManuallyMigratingQMCDRecordStack.h"
#import "ClassicWithBackgroundCoordinatorSQLiteQMCDRecordStack.h"
#import "InMemoryQMCDRecordStack.h"
#import "QMCDRecordLogging.h"


@implementation QMCDRecord (Setup)

+ (QMCDRecordStack *) setupSQLiteStack
{
    QMCDRecordStack *stack = [[SQLiteQMCDRecordStack alloc] init];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *)setupSQLiteStackWithStoreAtURL:(NSURL *)url;
{
    QMCDRecordStack *stack = [[SQLiteQMCDRecordStack alloc] initWithStoreAtURL:url];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *)setupSQLiteStackWithStoreNamed:(NSString *)storeName;
{
    QMCDRecordStack *stack = [[SQLiteQMCDRecordStack alloc] initWithStoreNamed:storeName];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupAutoMigratingStack;
{
    QMCDRecordStack *stack = [[AutoMigratingQMCDRecordStack alloc] init];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupAutoMigratingStackWithSQLiteStoreNamed:(NSString *)storeName;
{
    QMCDRecordStack *stack = [[AutoMigratingQMCDRecordStack alloc] initWithStoreNamed:storeName];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupAutoMigratingStackWithSQLiteStoreAtURL:(NSURL *)url;
{
    QMCDRecordStack *stack = [[AutoMigratingQMCDRecordStack alloc] initWithStoreAtURL:url];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupManuallyMigratingStack;
{
    QMCDRecordStack *stack = [[ManuallyMigratingQMCDRecordStack alloc] init];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupManuallyMigratingStackWithSQLiteStoreNamed:(NSString *)storeName;
{
    QMCDRecordStack *stack = [[ManuallyMigratingQMCDRecordStack alloc] initWithStoreNamed:storeName];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupManuallyMigratingStackWithSQLiteStoreAtURL:(NSURL *)url;
{
    QMCDRecordStack *stack = [[ManuallyMigratingQMCDRecordStack alloc] initWithStoreAtURL:url];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupClassicStack;
{
    QMCDRecordStack *stack = [[ClassicSQLiteQMCDRecordStack alloc] init];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupClassicStackWithSQLiteStoreNamed:(NSString *)storeName;
{
    QMCDRecordStack *stack = [[ClassicSQLiteQMCDRecordStack alloc] initWithStoreNamed:storeName];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupClassicStackWithSQLiteStoreAtURL:(NSURL *)storeURL;
{
    QMCDRecordStack *stack = [[ClassicSQLiteQMCDRecordStack alloc] initWithStoreAtURL:storeURL];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupStackWithInMemoryStore;
{
    QMCDRecordStack *stack = [[InMemoryQMCDRecordStack alloc] init];
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

+ (QMCDRecordStack *) setupiCloudStackWithLocalStoreNamed:(NSString *)localStore;
{
    ClassicSQLiteQMCDRecordStack *stack = [[ClassicSQLiteQMCDRecordStack alloc] initWithStoreNamed:localStore];
    stack.storeOptions = @{ NSPersistentStoreUbiquitousContentNameKey: localStore};
    [QMCDRecordStack setDefaultStack:stack];
    return stack;
}

@end
