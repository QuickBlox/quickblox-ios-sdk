//
//  UsersModuleDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "UsersDataSource.h"

@implementation UsersDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Sign In/Sign Out/Sign Up";
    }else if(section == 1){
        return @"Get";
    }else if(section == 2){
        return @"Edit";
    }else if(section == 3){
        return @"Delete";
    }
    
    return @"Reset";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 6;
    }else if(section == 1){
        return 15;
    }else if(section == 2){
        return 1;
    }else if(section == 3){
        return 2;
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // Sign In, Sign Out, Sign Up
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"User Login with login";
                    break;
                case 1:
                    cell.textLabel.text = @"User Login with email";
                    break;
                case 2:
                    cell.textLabel.text = @"User Login with social provider";
                    break;
                case 3:
                    cell.textLabel.text = @"User Login with social access token";
                    break;
                case 4:
                    cell.textLabel.text = @"User Logout";
                    break;
                case 5:
                    cell.textLabel.text = @"User Sign Up";
                    break;
                default:
                    break;
            }
            break;
            
            // Get
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Get users";
                    break;
                case 1:
                    cell.textLabel.text = @"Get users with extended request";
                    break;
                case 2:
                    cell.textLabel.text = @"Get user by ID";
                    break;
                case 3:
                    cell.textLabel.text = @"Get users with ids";
                    break;
                case 4:
                    cell.textLabel.text = @"Get user by login";
                    break;
                case 5:
                    cell.textLabel.text = @"Get users by logins";
                    break;
                case 6:
                    cell.textLabel.text = @"Get users by fullname";
                    break;
                case 7:
                    cell.textLabel.text = @"Get user by facebook ID";
                    break;
                case 8:
                    cell.textLabel.text = @"Get users by facebook IDs";
                    break;
                case 9:
                    cell.textLabel.text = @"Get user by twitter ID";
                    break;
                case 10:
                    cell.textLabel.text = @"Get users by twitter IDs";
                    break;
                case 11:
                    cell.textLabel.text = @"Get user by email";
                    break;
                case 12:
                    cell.textLabel.text = @"Get users by emails";
                    break;
                case 13:
                    cell.textLabel.text = @"Get users by tags";
                    break;
                case 14:
                    cell.textLabel.text = @"Get user by external ID";
                    break;
                default:
                    break;
            }
            
            break;
            
            // Edit
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Update user by ID";
                    break;
                default:
                    break;
            }
            break;
            
            // Delete
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Delete user by ID";
                    break;
                case 1:
                    cell.textLabel.text = @"Delete user by external ID";
                    break;
                default:
                    break;
            }
            
            break;
            
            // Reset
        case 4:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Reset user's password with email";
                    break;
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
