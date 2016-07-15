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
@property (nonatomic, copy) NSArray *sortedUsers;
@property (nonatomic, strong) NSArray *usersToAdd;
@property (nonatomic,strong) NSArray * excludedUsers;

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
        
		_users =  [[users copy] sortedArrayUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
			return [obj1.login compare:obj2.login options:NSNumericSearch];
		}];
        
        NSMutableArray * userIds  = [NSMutableArray array];
        
        [_users enumerateObjectsUsingBlock:^(QBUUser *obj, NSUInteger idx, BOOL *stop) {
            [userIds addObject:@(obj.ID)];
      
        }];
        
        _usersToAdd = [[[ServicesManager instance] sortedUsers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (ID IN %@)", userIds.copy]];
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
    _excludeUsersIDs = excludeUsersIDs;
    
	if  (excludeUsersIDs == nil) {
        self.excludedUsers = [NSArray array];
		return;
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

- (UIColor *)colorForRow:(NSInteger)row {
	
    UIColor * color = self.colors[row%self.colors.count];
    
    return color;
}

#pragma mark - UITableViewDataSource methods

- (UserTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell* cell  = [tableView dequeueReusableCellWithIdentifier:kUserTableViewCellIdentifier forIndexPath:indexPath];
 
    [self configureCell:cell atIndexPath:indexPath];

    cell.selectable = tableView.allowsMultipleSelection && indexPath.section == 0;
    
	return cell;
}

- (void)configureCell:(UserTableViewCell*)cell
          atIndexPath:(NSIndexPath*)indexPath {
    
    QBUUser *user = [self arrayForSection:indexPath.section][indexPath.row];
    cell.user = user;
    
    if (self.addStringLoginAsBeforeUserFullname) {
        cell.userDescription = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SA_STR_LOGIN_AS", nil), user.fullName];
    }
    else {
        cell.userDescription = user.fullName;
    }
    
    cell.userInteractionEnabled = (indexPath.section == 0);
    
    [cell setColorMarkerText:[NSString stringWithFormat:@"%zd", indexPath.row + 1] andColor:[self colorForRow:indexPath.row]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return [self arrayForSection:section].count;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString * title = nil;
    
    if (self.isEditMode) {
        
        switch (section) {
                
            case 0:
                
                title = self.usersToAdd.count ? @"Users to add" : @"There is nobody to add";
                break;
                
            case 1:

                title = @"Users in this dialog";
                break;
                
            default:
                break;
        }
    }
    
    return title;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isEditMode ? 2 : 1;
}

#pragma mark - Helpers
- (NSArray*)arrayForSection:(NSInteger)section {
    
    if (!self.isEditMode) {
        return self.users;
    }
    
    if (section == 0) {
        return self.usersToAdd;
    }
    else if (section == 1) {
        return self.users;
    }
    
    return nil;
}

@end
