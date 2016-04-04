//
//  NSPersistentStoreCoordinator+Additions.h
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (STKAdditions)

+ (NSPersistentStoreCoordinator *)stk_defaultPersistentsStoreCoordinator;

@end
