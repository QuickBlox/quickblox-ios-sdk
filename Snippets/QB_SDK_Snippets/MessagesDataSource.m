//
//  MessagesDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "MessagesDataSource.h"

@implementation MessagesDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 3;
        case 2:
            return 5;
        case 3:
            return 6;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"PushToken";
        case 1:
            return @"Subscription";
        case 2:
            return @"Event";;
            break;
        case 3:
            return @"Tasks";
            break;
            
        default:
            break;
    }
    
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // Push Token
        case 0:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create Push Token";
                }
                    break;
                    
                case 1:{
                    cell.textLabel.text = @"Delete Push Token";
                }
                    break;
            }
            break;
            
            // Subscription
        case 1:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create Subscription";
                }
                    break;
                    
                case 1:{
                    cell.textLabel.text = @"Get Subscriptions";
                }
                    break;
                    
                case 2:{
                    cell.textLabel.text = @"Delete Subscription";
                }
                    break;
            }
            
            break;
            
            // Event
        case 2:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create Event";
                }
                    break;
                    
                case 1:{
                    cell.textLabel.text = @"Get Event with ID";
                }
                    break;
                    
                case 2:{
                    cell.textLabel.text = @"Get Events";
                }
                    break;
                    
                case 3:{
                    cell.textLabel.text = @"Update Event";
                }
                    break;
                    
                case 4:{
                    cell.textLabel.text = @"Delete Event";
                }
                    break;
            }
            
            break;
            
            // Tasks
        case 3:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"TRegisterSubscription";
                }
                    break;
                    
                case 1:{
                    cell.textLabel.text = @"TUnregisterSubscription";
                }
                    break;
                    
                case 2:{
                    cell.textLabel.text = @"TSendPush to users' ids";
                }
                    break;
                    
                case 3:{
                    cell.textLabel.text = @"TSendPushWithText to users' ids";
                }
                    break;
                    
                case 4:{
                    cell.textLabel.text = @"TSendPush to users' tags";
                }
                    break;
                case 5:{
                    cell.textLabel.text = @"TSendPushWithText to users' tags";
                }
                    break;
            }
            
        default:
            break;
    }    
    return cell;
}


@end
