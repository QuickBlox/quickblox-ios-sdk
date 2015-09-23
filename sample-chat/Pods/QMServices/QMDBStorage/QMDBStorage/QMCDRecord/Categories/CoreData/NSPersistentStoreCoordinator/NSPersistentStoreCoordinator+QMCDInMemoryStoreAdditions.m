//
//  NSPersistentStoreCoordinator+QMCDInMemoryStoreAdditions.m
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSPersistentStoreCoordinator+QMCDInMemoryStoreAdditions.h"
#import "NSDictionary+QMCDRecordAdditions.h"
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "QMCDRecordStack.h"
#import "NSError+QMCDRecordErrorHandling.h"

@implementation NSPersistentStoreCoordinator (QMCDInMemoryStoreAdditions)

#pragma mark - Public Class Methods

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithInMemoryStore
{
	NSManagedObjectModel *defaultStackModel = [[QMCDRecordStack defaultStack] model];

    return [self QM_coordinatorWithInMemoryStoreWithModel:defaultStackModel];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithInMemoryStoreWithModel:(NSManagedObjectModel *)model
{
    return [self QM_coordinatorWithInMemoryStoreWithModel:model withOptions:nil];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithInMemoryStoreWithModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options
{
	NSPersistentStoreCoordinator *coordinator = [[self alloc] initWithManagedObjectModel:model];

    [coordinator QM_addInMemoryStoreWithOptions:options];

    return coordinator;
}

#pragma mark - Public Instance Methods

- (NSPersistentStore *) QM_addInMemoryStore
{
    return [self QM_addInMemoryStoreWithOptions:nil];
}

- (NSPersistentStore *) QM_addInMemoryStoreWithOptions:(NSDictionary *)options
{
    NSError *error;
    NSPersistentStore *store = [self addPersistentStoreWithType:NSInMemoryStoreType
                                                  configuration:nil
                                                            URL:nil
                                                        options:options
                                                          error:&error];
    if (!store)
    {
        [[error QM_coreDataDescription] QM_logToConsole];
    }

    return store;
}

@end
