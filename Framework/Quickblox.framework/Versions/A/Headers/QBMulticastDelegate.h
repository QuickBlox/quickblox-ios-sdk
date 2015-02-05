//
//  QBMulticastDelegate.h
//  Quickblox
//
//  Created by Andrey on 01.10.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBMulticastDelegate : NSObject

// Adds the given delegate implementation to the list of observers
- (void)addDelegate:(id)delegate;

// Removes the given delegate implementation from the list of observers
- (void)removeDelegate:(id)delegate;

// Removes all delegates
- (void)removeAllDelegates;

// Hashtable of all delegates
- (NSHashTable *)delegates;

@end
