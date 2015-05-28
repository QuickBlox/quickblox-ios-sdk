//
//  ReachabilityManager.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReachabilityManager : NSObject

+ (instancetype)instance;

- (void)startNotifier;

- (BOOL)isReachable;

@end
