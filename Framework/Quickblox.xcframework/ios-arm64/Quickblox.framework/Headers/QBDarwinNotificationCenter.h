//
//  QBDarwinNotificationCenter.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A notification that enables the broadcast of information to registered observers
 between extensions with the same QuickBlox application id.
 
 @discussion The Darwin notification center is a system mechanism on iOS and OS X to send signals across process boundaries. It's useful to exchange information between two or more running processes such as an iPhone app notifying a WatchKit/Share/Siri.... Extension that new data has arrived.
 Is based on Darwin notification center. @see https://developer.apple.com/library/content/documentation/Darwin/Conceptual/MacOSXNotifcationOv/DarwinNotificationConcepts/DarwinNotificationConcepts.html#//apple_ref/doc/uid/TP40005947-CH5-SW1
 */
@interface QBDarwinNotificationCenter : NSObject

/**
 Returns the process’s default darwin notification center
 */
@property (nonatomic, readonly, class) QBDarwinNotificationCenter *defaultCenter;

/**
 Adds an entry to the receiver’s
 
 @param name The name of the notification for which to register the observer; that is,
 only notifications with this name are delivered to the observer.
 @param block The block to be executed when the notification is received.
 
 @return An opaque object to act as the observer.
 */
- (id <NSObject>)addObserverForName:(NSNotificationName)name usingBlock:(dispatch_block_t)block;

/**
 Removes all the entries specifying a given observer.

 @param observer The observer to remove. Must not be nil.
 */
- (void)removeObserver:(id)observer;

/**
 Posts a given notification to the receiver.

 @param name The notification to post. This value must not be nil.
 */
- (void)postNotificationName:(NSNotificationName)name;

@end

NS_ASSUME_NONNULL_END
