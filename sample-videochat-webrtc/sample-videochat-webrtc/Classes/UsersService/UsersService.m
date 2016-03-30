//
//  UsersService.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 3/29/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "UsersService.h"

@implementation UsersService

+ (void)allUsersWithTags:(NSArray *)tags perPageLimit:(NSUInteger)limit
			successBlock:(void(^)(NSArray *usersObjects))successBlock
			  errorBlock:(void(^)(QBResponse *response))errorBlock {
	
	NSParameterAssert(tags);
	
	QBGeneralResponsePage *responsePage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:limit];
	__block BOOL cancel = NO;
	
	__block dispatch_block_t t_request;
	
	NSMutableArray *allUsers = [NSMutableArray array];
	
	dispatch_block_t request = [^{
		
		[QBRequest usersWithTags:tags page:responsePage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
			
			responsePage.currentPage += 1;
			
			[allUsers addObjectsFromArray:users];
			
			if (responsePage.currentPage * responsePage.perPage <= responsePage.totalEntries) {
				cancel = YES;
			}
			
			if (!cancel) {
				t_request();
			} else {
				if (successBlock) {
					successBlock(allUsers);
				}
			}
			
		} errorBlock:errorBlock];
	} copy];
	
	
	t_request = request;
	request();
}


@end
