//
//  UsersService.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 3/29/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersService : NSObject

+ (void)allUsersWithTags:(NSArray *)tags perPageLimit:(NSUInteger)limit
			successBlock:(void(^)(NSArray *usersObjects))successBlock
			  errorBlock:(void(^)(QBResponse *response))errorBlock;

@end
