//
//  NSPersistentStoreCoordinator+Additions.m
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "NSPersistentStoreCoordinator+STKAdditions.h"

static NSPersistentStoreCoordinator *defaultCoordinator;

@implementation NSPersistentStoreCoordinator (STKAdditions)

+ (NSPersistentStoreCoordinator *)stk_defaultPersistentsStoreCoordinator {
    
    if (!defaultCoordinator) {
        NSURL *urlForDataModel = [[NSBundle mainBundle] URLForResource:@"StickerModel" withExtension:@"momd"];
        
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:urlForDataModel];
        
        NSAssert(model != nil, @"Error init managed object model");
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        
        
        defaultCoordinator = coordinator;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"StickerModel.sqlite"];
        
        
        NSError *error = nil;
        
        // Adding the journalling mode recommended by apple
        NSMutableDictionary *sqliteOptions = [NSMutableDictionary dictionary];
        [sqliteOptions setObject:@"WAL" forKey:@"journal_mode"];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 sqliteOptions, NSSQLitePragmasOption,
                                 nil];
        
        NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        
        
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
        
    }
    
    return defaultCoordinator;
}

@end
