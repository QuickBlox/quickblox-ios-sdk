//
//  RatingsDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "RatingsDataSource.h"

@implementation RatingsDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
            // Game Mode
        case 0:
            return 5;
            break;
            
            // Score
        case 1:
            return 6;
            break;
            
            // Average
        case 2:
            return 2;
            break;
            
            // Game Mode Parameter Value
        case 3:
            return 3;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Game Mode";
        case 1:
            return @"Score";
        case 2:
            return @"Average";
        case 3:
            return @"Game Mode Parameter Value";
            
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
            // Game Mode
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create game mode";
                    break;
                case 1:
                    cell.textLabel.text = @"Get game mode with ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Get game modes";
                    break;
                case 3:
                    cell.textLabel.text = @"Update game mode";
                    break;
                case 4:
                    cell.textLabel.text = @"Delete game mode with ID";
                    break;
            }
            break;
            
            // Score
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create score";
                    break;
                case 1:
                    cell.textLabel.text = @"Get score with ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Update score";
                    break;
                case 3:
                    cell.textLabel.text = @"Delete score with ID";
                    break;
                case 4:
                    cell.textLabel.text = @"Get top N scores";
                    break;
                case 5:
                    cell.textLabel.text = @"Get scores with user ID";
                    break;
            }
            break;
            
            // Average
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Get average with game mode ID";
                    break;
                case 1:
                    cell.textLabel.text = @"Get averages for application";
                    break;
            }
            break;
            
            // Game mode parameter value
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create game mode parameter value";
                    break;
                case 1:
                    cell.textLabel.text = @"Update game mode parameter value";
                    break;
                case 2:
                    cell.textLabel.text = @"Get game mode parameter value with ID";
                    break;
            }
            break;
            
            
        default:
            break;
    }
    
    
    return cell;
}

@end
