//
//  UsersDataSource.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersDataSource.h"
#import "StorageManager.h"
#import "UserTableViewCell.h"

@interface UsersDataSource()
@property (nonatomic, strong) NSArray *colors;
@end

@implementation UsersDataSource

NSString *const kUserTableViewCellIdentifier = @"UserTableViewCellIdentifier";

- (instancetype)init {
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
	}
	return self;
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
	return [StorageManager.instance.users indexOfObject:user];
}

- (UIColor *)colorForUser:(QBUUser *)user {
	NSUInteger idx = [StorageManager.instance.users indexOfObject:user];
	return self.colors[idx];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserTableViewCellIdentifier forIndexPath:indexPath];
	
	QBUUser *user = (QBUUser *)StorageManager.instance.users[indexPath.row];
	
	cell.userDescription = user.fullName;
	[cell setColorMarkerText:[NSString stringWithFormat:@"%zd", indexPath.row+1] andColor:[self colorForUser:user]];
	return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return StorageManager.instance.users.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end
