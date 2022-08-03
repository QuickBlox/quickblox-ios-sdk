//
//  UserList+Search.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 27.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserList.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserList (Search)
- (void)searchWithName:(NSString *)name page:(NSUInteger)pageNumber completion:(FetchUsersCompletion)completion;
- (void)searchNextWithName:(NSString *)name completion:(FetchUsersCompletion)completion;
@end

NS_ASSUME_NONNULL_END
