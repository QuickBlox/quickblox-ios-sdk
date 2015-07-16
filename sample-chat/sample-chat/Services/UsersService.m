//
//  UsersService.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersService.h"
#import "StorageManager.h"
#import "QBServicesManager.h"

@implementation UsersService

- (instancetype)initWithContactListService:(QMContactListService *)contactListService {
	self = [super init];
	if( self ) {
		_contactListService = contactListService;
	}
	return self;
}

- (void)cachedUsersWithCompletion:(void(^)(NSArray *users))completion {
	// check memory storage
	NSArray *memoryUsers = [self.contactListService.usersMemoryStorage usersSortedByKey:@"fullName" ascending:YES];
	if (memoryUsers != nil && memoryUsers.count != 0) {
		StorageManager.instance.users = memoryUsers;
		completion(memoryUsers);
        return;
	}
	
	// check CoreData storage
	[QMContactListCache.instance usersSortedBy:@"fullName" ascending:YES completion:^(NSArray *users) {
		StorageManager.instance.users = users;
		completion(users);
	}];
}

- (void)downloadLatestUsersWithSuccessBlock:(void(^)(NSArray *latestUsers))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock {
	__weak __typeof(self)weakSelf = self;
	
//	NSMutableDictionary *dict = @{@"updated_at[gt]": [@([self timestampFromLatestCustomObject]) stringValue] }.mutableCopy;
    NSString* environment = nil;
#if DEV
    environment = @"dev";
#endif
    
#if QA
    environment = @"qa";
#endif
    
#if RELEASE
    environment = @"release";
#endif
    
    [QBRequest usersWithTags:@[environment] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        __typeof(self) strongSelf = weakSelf;
        
        NSMutableArray* mutableUsers = [users mutableCopy];
		[mutableUsers sortUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
			return [obj1.login compare:obj2.login options:NSNumericSearch];
		}];

		[strongSelf.contactListService.usersMemoryStorage addUsers:users];
		[QMContactListCache.instance insertOrUpdateUsers:[mutableUsers copy] completion:nil];

		StorageManager.instance.users = [mutableUsers copy];

		if (successBlock != nil) {
			successBlock([mutableUsers copy]);
		}
    } errorBlock:^(QBResponse *response) {
		if (errorBlock != nil) {
			errorBlock(response);
		}
		NSLog(@"error: %@", response.error.error);
    }];
}

- (QBUUser *)userWithID:(NSNumber *)userID {
	
	__block QBUUser *resultUser = nil;
	[StorageManager.instance.users enumerateObjectsUsingBlock:^(QBUUser *user,
																NSUInteger idx,
																BOOL *stop) {
		
		if (user.ID == userID.integerValue) {
			resultUser =  user;
			*stop = YES;
		}
	}];
	
	return resultUser;
}

- (NSArray *)usersWithoutCurrentUser {
	NSArray *usersWithoutCurrentUser = StorageManager.instance.users;
	if( [QBSession currentSession].currentUser ) {
		usersWithoutCurrentUser = [usersWithoutCurrentUser filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
			QBUUser *user = (QBUUser *)evaluatedObject;
			return user.ID != [QBSession currentSession].currentUser.ID;
		}]];
	}
	
	return usersWithoutCurrentUser;
}

- (NSArray *)idsWithUsers:(NSArray *)users {
	
	NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
	[users enumerateObjectsUsingBlock:^(QBUUser  *obj,
										NSUInteger idx,
										BOOL *stop){
		[ids addObject:@(obj.ID)];
	}];
	
	return [ids copy];
}

- (void)retrieveUsersWithIDs:(NSArray *)usersIDs completion:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))completion {
	[self.contactListService retrieveUsersWithIDs:usersIDs forceDownload:NO completion:completion];
}

@end
