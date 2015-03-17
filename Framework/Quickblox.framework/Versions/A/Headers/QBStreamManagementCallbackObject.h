//
//  QBStreamManagementCallbackObject.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/23/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBChatMessage;
@interface QBStreamManagementCallbackObject : NSObject

@property (copy, nonatomic) void (^callbackBlock)(NSError *);
@property (assign, nonatomic) NSUInteger currentNumberOfStanzasSent;
@property (copy, nonatomic) id object;

@end
