//
//  UsersDataSource.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersDataSource.h"
#import "UserTableViewCell.h"
#import "ServicesManager.h"

@interface UsersDataSource()
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, copy) NSArray *customUsers;
@end

@implementation UsersDataSource

- (instancetype)initWithUsers:(NSArray *)users {
	self = [super init];
	if( self) {
		_colors =
		@[[UIColor colorWithRed:0.992 green:0.510 blue:0.035 alpha:1.000],
		  [UIColor colorWithRed:0.039 green:0.376 blue:1.000 alpha:1.000],
		  [UIColor colorWithRed:0.984 green:0.000 blue:0.498 alpha:1.000],
		  [UIColor colorWithRed:0.204 green:0.644 blue:0.251 alpha:1.000],
		  [UIColor colorWithRed:0.580 green:0.012 blue:0.580 alpha:1.000],
		  [UIColor colorWithRed:0.396 green:0.580 blue:0.773 alpha:1.000],
		  [UIColor colorWithRed:0.765 green:0.000 blue:0.086 alpha:1.000],
		  [UIColor colorWithWhite:0.537 alpha:1.000],
		  [UIColor colorWithRed:0.786 green:0.706 blue:0.000 alpha:1.000],
		  [UIColor colorWithRed:0.740 green:0.624 blue:0.797 alpha:1.000]];
		_excludeUsersIDs = @[];
		_customUsers =  [[users copy] sortedArrayUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
			return [obj1.login compare:obj2.login options:NSNumericSearch];
		}];
		_users = _customUsers == nil ? [[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers] : _customUsers;
	}
	return self;
	
}
- (void)addUsers:(NSArray *)users {
	NSMutableArray *mUsers;
	if( _users != nil ){
		mUsers = [_users mutableCopy];
	}
	else {
		mUsers = [NSMutableArray array];
	}
	[mUsers addObjectsFromArray:users];
	_users = [mUsers copy];
}

- (instancetype)init {
	return [self initWithUsers:[[ServicesManager instance] sortedUsers]];
}

- (void)setExcludeUsersIDs:(NSArray *)excludeUsersIDs {
	if  (excludeUsersIDs == nil) {
		_users = self.customUsers == nil ? self.customUsers : [[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers];
		return;
	}
	if ([excludeUsersIDs isEqualToArray:self.users]) {
		return;
	}
	if (self.customUsers == nil) {
		_users = [[[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (ID IN %@)", self.excludeUsersIDs]];
	} else {
		_users = self.customUsers;
	}
	// add excluded users to future remove
	NSMutableArray *excludedUsers = [NSMutableArray array];
	[_users enumerateObjectsUsingBlock:^(QBUUser *obj, NSUInteger idx, BOOL *stop) {
		for (NSNumber *excID in excludeUsersIDs) {
			if (obj.ID == excID.integerValue) {
				[excludedUsers addObject:obj];
			}
		}
	}];
	
	//remove excluded users
	NSMutableArray *mUsers = [_users mutableCopy];
	[mUsers removeObjectsInArray:excludedUsers];
	_users = [mUsers copy];
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
    
	return [self.users indexOfObject:user];
}

- (UIColor *)colorForUser:(QBUUser *)user {
	
    UIColor *defaultColor = [UIColor blackColor];
    NSUInteger indexOfUser = [self indexOfUser:user];
    
    if (indexOfUser < self.colors.count) {
        
        return self.colors[indexOfUser];
    }
    else {
        
        return defaultColor;
    }
}

#pragma mark - UITableViewDataSource methods

- (UserTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserTableViewCellIdentifier forIndexPath:indexPath];
	
	QBUUser *user = (QBUUser *)self.users[indexPath.row];
	
	cell.user = user;
    if (self.addStringLoginAsBeforeUserFullname) {
        cell.userDescription = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SA_STR_LOGIN_AS", nil), user.fullName];
    } else {
        cell.userDescription = user.fullName;
    }
    
	[cell setColorMarkerText:[NSString stringWithFormat:@"%zd", indexPath.row + 1] andColor:[self colorForUser:user]];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.users.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end
