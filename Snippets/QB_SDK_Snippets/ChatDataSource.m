//
//  ChatModuleDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "ChatDataSource.h"

@implementation ChatDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 3;
            break;
        case 1:
            numberOfRows = 3;
            break;
        case 2:
            numberOfRows = 2;
            break;
        case 3:
            numberOfRows = 13;
            break;
        case 4:
            numberOfRows = 4;
            break;
        case 5:
            numberOfRows = 8;
            break;
        case 6:
            numberOfRows = 7;
            break;
        case 7:
            numberOfRows = 2;
            break;
        case 8:
            numberOfRows = 1;
            break;
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* headerTitle;
    switch (section) {
        case 0:
            headerTitle = @"Sign In/Sign Out";
            break;
        case 1:
            headerTitle = @"Presence";
            break;
        case 2:
            headerTitle = @"1 to 1 chat";
            break;
        case 3:
            headerTitle = @"Rooms";
            break;
        case 4:
            headerTitle = @"Contact List";
            break;
        case 5:
            headerTitle = @"History";
            break;
        case 6:
            headerTitle = @"Privacy";
            break;
        case 7:
            headerTitle = @"Typing status";
            break;
        case 8:
            headerTitle = @"Delivered status";
            break;
        default:
            headerTitle = @"";
            break;
            
    }
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // section Sign In/Sign Out
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Login"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Is Logged In"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Logout"];
                    break;
                    
                default:
                    break;
            }
            break;
            
            
            // Presence section
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Send presence"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Send presence with status"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Send direct presence with status"];
                    break;
                    
                default:
                    break;
            }
            break;
            
            
            // section 1 to 1 chat
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Send message"];
                    break;
                
                case 1:
                    [cell.textLabel setText:@"Send message with 'sent' callback"];
                    break;
            }
            break;
            
            
            // section Rooms
        case 3:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Create public room"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Create only members room"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Join room"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Leave room"];
                    break;
                    
                case 4:
                    [cell.textLabel setText:@"Send message to room"];
                    break;
                    
                case 5:
                    [cell.textLabel setText:@"Send presence to room"];
                    break;
                    
                case 6:
                    [cell.textLabel setText:@"Request all rooms"];
                    break;
                    
                case 7:
                    [cell.textLabel setText:@"Add users to room"];
                    break;
                    
                case 8:
                    [cell.textLabel setText:@"Delete users from room"];
                    break;
                    
                case 9:
                    [cell.textLabel setText:@"Request room users"];
                    break;
                    
                case 10:
                    [cell.textLabel setText:@"Request room online users"];
                    break;
                    
                case 11:
                    [cell.textLabel setText:@"Request room information"];
                    break;
                    
                case 12:
                    [cell.textLabel setText:@"Destroy room"];
                    break;
                    
                default:
                    break;
            }
            break;
            
            // section Contact list
        case 4:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Add user to contact list request"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Confirm add request"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Reject add request"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Remove user from contact list"];
                    break;
                    
                default:
                    break;
            }
            break;
        case 5:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Get Dialogs"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Get Messages"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Create Dialog"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Update Dialog"];
                    break;
                    
                case 4:
                    [cell.textLabel setText:@"Create Message"];
                    break;
                    
                case 5:
                    [cell.textLabel setText:@"Update Message"];
                    break;
                    
                case 6:
                    [cell.textLabel setText:@"Mark Message as read"];
                    break;
                    
                case 7:
                    [cell.textLabel setText:@"Delete Message"];
                    break;
                    
                default:
                    break;
            }
            break;
        case 6:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Create Privacy List"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Delete Privacy List"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Block user"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Unblock user"];
                    break;
                case 4:
                    [cell.textLabel setText:@"Retrieve list names"];
                    break;
                case 5:
                    [cell.textLabel setText:@"Retrieve 'public' list"];
                    break;
                case 6:
                    [cell.textLabel setText:@"Set 'public' list as default"];
                    break;
                    
                default:
                    break;
            }
            break;
        case 7:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Send typing"];
                    break;
                case 1:
                    [cell.textLabel setText:@"Send stop typing"];
                    break;
            }
            break;
        case 8:
            [cell.textLabel setText:@"Mark as delivered"];
            break;
        default:
            break;
    }
    
    return cell;
}

@end
