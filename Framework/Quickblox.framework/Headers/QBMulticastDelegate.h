//
//  QBMulticastDelegate.h
//  Quickblox
//
//  Created by Andrey on 01.10.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

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
- (NSHashTable QB_GENERIC(id) *)delegates;

@end

NS_ASSUME_NONNULL_END
