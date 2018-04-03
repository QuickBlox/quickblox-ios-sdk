//
//  UsersDataSource.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 06/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UsersDataSource.h"
#import "UserTableViewCell.h"
#import <Quickblox/Quickblox.h>
#import "QBProfile.h"
#import "PlaceholderGenerator.h"

@implementation UsersDataSource

// MARK: Construction

+ (instancetype)usersDataSource {
    return [[self alloc] initWithSortSelector:@selector(fullName)];
}

// MARK: Public

- (QBUUser *)userWithID:(NSUInteger)ID {
    
    for (QBUUser *user in self.objects) {
        
        if (user.ID == ID) {
            return user;
        }
    }
    
    return nil;
}

// MARK: UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    QBUUser *user = self.objects[indexPath.row];
    BOOL selected = [self.selectedObjects containsObject:user];
    UIImage *userImage = [PlaceholderGenerator placeholderWithSize:CGSizeMake(32, 32) title:user.fullName];
    
    [cell setFullName:user.fullName];
    [cell setCheck:selected];
    [cell setUserImage:userImage];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *str = [NSString stringWithFormat:@"Select users to create chat dialog with (%tu)", self.selectedObjects.count];
    
    return NSLocalizedString(str, nil);
}

@end
