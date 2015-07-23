//
//  NSManagedObjectContext+Additions.m
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "NSManagedObjectContext+STKAdditions.h"
#import "NSPersistentStoreCoordinator+STKAdditions.h"
#import "STKUtility.h"

static NSManagedObjectContext *mainContext;
static NSManagedObjectContext *backgroundContext;

@implementation NSManagedObjectContext (Additions)

+ (void)stk_setupContextStackWithPersistanceStore:(NSPersistentStoreCoordinator*) coordinator {
    
    NSManagedObjectContext *backgroundQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundQueueContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    NSManagedObjectContext *mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contexDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    if (coordinator) {
        backgroundQueueContext.persistentStoreCoordinator = coordinator;
        mainQueueContext.persistentStoreCoordinator = coordinator;

    }
    
    mainContext = mainQueueContext;
    backgroundContext = backgroundQueueContext;
    
}

+ (void)contexDidSave:(NSNotification*) notification {
    
    NSManagedObjectContext *contextForMerge = nil;
    
    if (notification.object == mainContext) {
        contextForMerge = backgroundContext;
    } else if (notification.object == backgroundContext) {
        contextForMerge = mainContext;
    }
    
    [contextForMerge mergeChangesFromContextDidSaveNotification:notification];
}

+ (NSManagedObjectContext *)stk_defaultContext {
    
    if (!mainContext) {
        [self stk_setupContextStackWithPersistanceStore:[NSPersistentStoreCoordinator stk_defaultPersistentsStoreCoordinator]];
    }
    
    
    return mainContext;
}

+ (NSManagedObjectContext*) stk_backgroundContext {
    
    if (!backgroundContext) {
        [self stk_setupContextStackWithPersistanceStore:[NSPersistentStoreCoordinator stk_defaultPersistentsStoreCoordinator]];
    }
    return backgroundContext;
}

@end
