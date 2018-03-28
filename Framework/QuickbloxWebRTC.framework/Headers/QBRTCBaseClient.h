//
//  QBRTCBaseClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCBaseClientDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCBaseClient class interface.
 *  This class represents basic client methods.
 */
@interface QBRTCBaseClient : NSObject

// unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Client instance singleton.
 *
 *  @return Client instance
 */
+ (instancetype)instance;

/**
 *  Add delegate to the observers list.
 *
 *  @param delegate class that conforms to QBRTCBaseClientDelegate protocol
 */
- (void)addDelegate:(id<QBRTCBaseClientDelegate>)delegate;

/**
 *  Remove delegate from the observers list.
 *
 *  @param delegate class that conforms to QBRTCBaseClientDelegate protocol
 */
- (void)removeDelegate:(id<QBRTCBaseClientDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
