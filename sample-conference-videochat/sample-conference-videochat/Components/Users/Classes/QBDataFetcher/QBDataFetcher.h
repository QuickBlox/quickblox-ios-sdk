//
//  QBDataFetcher.h
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBDataFetcher : NSObject

+ (void)fetchDialogs:(void(^)(NSArray *dialogs))completion;
+ (void)fetchUsers:(void(^)(NSArray *users))completion;

@end
