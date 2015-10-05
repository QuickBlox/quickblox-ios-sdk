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

@interface QBMulticastDelegate : NSObject

// Adds the given delegate implementation to the list of observers
- (void)addDelegate:(QB_NONNULL id)delegate;

// Removes the given delegate implementation from the list of observers
- (void)removeDelegate:(QB_NONNULL id)delegate;

// Removes all delegates
- (void)removeAllDelegates;

// Hashtable of all delegates
- (QB_NONNULL NSHashTable QB_GENERIC(id) *)delegates;

@end
