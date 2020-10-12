//
//  Reachability.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NetworkStatus)  {
    
    NetworkStatusNotReachable = 0,
    NetworkStatusReachableViaWiFi,
    NetworkStatusReachableViaWWAN
};

typedef void(^NetworkStatusBlock)(NetworkStatus status);

NS_ASSUME_NONNULL_BEGIN

@interface Reachability : NSObject

@property (copy, nonatomic, nullable)  NetworkStatusBlock networkStatusBlock;

+ (instancetype)instance;

- (NetworkStatus)networkStatus;

@end

NS_ASSUME_NONNULL_END
