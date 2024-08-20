//
//  QBSessionManager.h
//  QuickBlox
//
//  Created by QuickBlox team on 08.09.14.
//
//

#import <Foundation/Foundation.h>

@class QBASession;

NS_ASSUME_NONNULL_BEGIN

@interface QBSessionManager : NSObject

/** The current session manager instance. */
@property (nonatomic, strong, readonly, class) QBSessionManager *instance;

/**
 Start session with token
 
 Use QBSessionManagerDelegate callbacks to detect session states
 @note disables auto create session
 
 @param token Unique auto generated sequence of numbers which identify API User as the legitimate user of our system
 */
- (void)startSessionWithToken:(NSString *)token;

@end

/**
 QBSessionDelegate protocol definition.
 This protocol defines methods signatures for callbacks.
 Implement this protocol in your class and add [QBSessionManager instance].addDelegate to your implementation
 instance to receive callbacks from QBSessionManager
 */
@protocol QBSessionManagerDelegate <NSObject>

/**
 Called whenever QBSession did start.
 
 Use this callback to detect that session  start successfully.
 */
- (void)sessionManager:(QBSessionManager *)manager
didStartSessionWithDetails:(QBASession *)details;

/**
 Called whenever QBSession did not  start.
 
 Use this callback to detect that session start fail.
 */
- (void)sessionManager:(QBSessionManager *)manager
didNotStartSessionWithError:(NSError * _Nullable)error;

/**
 Called whenever QBSession did expire.
 
 Use this callback for starting update session process.
 */
- (void)sessionManagerDidExpireSession:(QBSessionManager *)manager;

@end

@interface QBSessionManager (SessionDelegate)

/**
 Adds the given delegate implementation to the list of observers.
 
 @param delegate The delegate to add.
 */
- (void)addDelegate:(id<QBSessionManagerDelegate>)delegate;

/**
 Removes the given delegate implementation from the list of observers.
 
 @param delegate The delegate to remove.
 */
- (void)removeDelegate:(id<QBSessionManagerDelegate>)delegate;

/** Removes all delegates. */
- (void)removeAllDelegates;

/** Returns array of all delegates. */
- (NSArray<id<QBSessionManagerDelegate>> *)delegates;

@end

NS_ASSUME_NONNULL_END
