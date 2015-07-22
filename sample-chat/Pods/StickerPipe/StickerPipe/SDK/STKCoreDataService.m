//
//  STKCoreDataService.m
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKCoreDataService.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSPersistentStoreCoordinator+STKAdditions.h"

@implementation STKCoreDataService

+ (void) setupCoreData {
    
    NSPersistentStoreCoordinator *coordinator = [NSPersistentStoreCoordinator stk_defaultPersistentsStoreCoordinator];
    
    [NSManagedObjectContext stk_setupContextStackWithPersistanceStore:coordinator];
}

@end
