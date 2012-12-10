//
//  QBUUsersGetByTagsQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 6/7/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBUUsersGetByTagsQuery : QBUUserQuery{
}
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) PagedRequest *pagedRequest;

- (id)initWithTags:(NSArray *)_tags;
- (id)initWithTags:(NSArray *)_tags pagedRequest:(PagedRequest *)_pagedRequest;

@end
