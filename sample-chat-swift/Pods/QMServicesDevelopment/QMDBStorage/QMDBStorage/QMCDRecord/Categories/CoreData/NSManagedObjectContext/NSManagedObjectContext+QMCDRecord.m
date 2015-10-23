//
//  NSManagedObjectContext+QMCDRecord.m
//
//  Created by Injoit on 11/23/09.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "QMCDRecordStack.h"
#import "QMCDRecordLogging.h"
#import <objc/runtime.h>

NSString * QM_concurrencyStringFromType(NSManagedObjectContextConcurrencyType type);
NSString * QM_concurrencyStringFromType(NSManagedObjectContextConcurrencyType type)
{
    if (type == NSPrivateQueueConcurrencyType) { return @"Private Queue"; }
    if (type == NSMainQueueConcurrencyType) { return @"Main Queue"; }
    if (type == NSConfinementConcurrencyType) {return @"Confinement"; }

    return @"Unknown Concurrency";
}

static id iCloudSetupNotificationObserver = nil;

static NSString * const kQMCDRecordNSManagedObjectContextWorkingName = @"kNSManagedObjectContextWorkingName";

@implementation NSManagedObjectContext (QMCDRecord)

- (NSString *) QM_description;
{
    NSString *onMainThread = [NSThread isMainThread] ? @"*** MAIN THREAD ***" : @"*** BACKGROUND THREAD ***";

    return [NSString stringWithFormat:@"%@ on %@", [self QM_workingName], onMainThread];
}

- (NSString *) QM_debugDescription;
{
    return [NSString stringWithFormat:@"<%@ (%p)> %@ (%@ Concurrency)", NSStringFromClass([self class]), self, [self QM_description], QM_concurrencyStringFromType([self concurrencyType])];
}

- (NSString *) QM_parentChain;
{
    NSMutableString *familyTree = [@"\n" mutableCopy];
    NSManagedObjectContext *currentContext = self;
    do
    {
        [familyTree appendFormat:@"- %@ (%p) %@\n", [currentContext QM_workingName], currentContext, (currentContext == self ? @"(*)" : @"")];
    }
    while ((currentContext = [currentContext parentContext]));

    return [NSString stringWithString:familyTree];
}

- (void) QM_obtainPermanentIDsForObjects:(NSArray *)objects;
{
    NSError *error = nil;
    BOOL success = [self obtainPermanentIDsForObjects:objects error:&error];
    if (!success)
    {
        [[error QM_coreDataDescription] QM_logToConsole];
    }
}

+ (NSManagedObjectContext *) QM_context;
{
    return [self QM_privateQueueContext];
}

+ (NSManagedObjectContext *) QM_confinementContext;
{
    NSManagedObjectContext *context = [[self alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context QM_setWorkingName:@"Confinement"];
    return context;
}

+ (NSManagedObjectContext *) QM_confinementContextWithParent:(NSManagedObjectContext *)parentContext;
{
    NSManagedObjectContext *context = [self QM_confinementContext];
    [context setParentContext:parentContext];
    return context;
}

+ (NSManagedObjectContext *) QM_mainQueueContext;
{
    NSManagedObjectContext *context = [[self alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context QM_setWorkingName:@"Main Queue"];
    return context;
}

+ (NSManagedObjectContext *) QM_privateQueueContext;
{
    NSManagedObjectContext *context = [[self alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context QM_setWorkingName:@"Private Queue"];
    return context;
}

+ (NSManagedObjectContext *) QM_privateQueueContextWithStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
	NSManagedObjectContext *context = nil;
    if (coordinator != nil)
	{
        context = [self QM_privateQueueContext];
        
        [context performBlockAndWait:^{
            [context setPersistentStoreCoordinator:coordinator];
        }];
        
        QMCDLogInfo(@"-> Created Context %@", [context QM_workingName]);
    }
    return context;
}

- (void) QM_setWorkingName:(NSString *)workingName;
{
    [[self userInfo] setObject:workingName forKey:kQMCDRecordNSManagedObjectContextWorkingName];
}

- (NSString *) QM_workingName;
{
    NSString *workingName = [[self userInfo] objectForKey:kQMCDRecordNSManagedObjectContextWorkingName];
    if ([workingName length] == 0)
    {
        workingName = @"UNNAMED";
    }
    return workingName;
}


@end
