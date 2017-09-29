//
//  QBMulticastDelegate.h
//  Quickblox
//
//  Created by QuickBlox team on 01.10.14.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBMulticastDelegate : NSObject

/**
 *  Adds the given delegate implementation to the list of observers.
 *
 *  @param delegate delegate to add
 */
- (void)addDelegate:(id)delegate;

/**
 *  Removes the given delegate implementation from the list of observers.
 *
 *  @param delegate delegate to remove
 */
- (void)removeDelegate:(id)delegate;

/**
 *  Removes all delegates.
 */
- (void)removeAllDelegates;

/**
 *  Hashtable of all delegates.
 */
- (NSHashTable <id> *)delegates;

@end

NS_ASSUME_NONNULL_END
