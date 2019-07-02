//
//  Reachability.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QBNetworkStatus)  {
    
    QBNetworkStatusNotReachable = 0,
    QBNetworkStatusReachableViaWiFi,
    QBNetworkStatusReachableViaWWAN
};

typedef void(^QBNetworkStatusBlock)(QBNetworkStatus status);

NS_ASSUME_NONNULL_BEGIN

@interface Reachability : NSObject

@property (copy, nonatomic, nullable)  QBNetworkStatusBlock networkStatusBlock;

+ (instancetype)instance;

- (QBNetworkStatus)networkStatus;

@end

NS_ASSUME_NONNULL_END
