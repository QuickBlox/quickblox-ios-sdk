//
//  CustomObjectsDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "CustomObjectsDataSource.h"

@implementation CustomObjectsDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }else if(section == 1){
        return 3;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Get object by ID";
                break;
            case 1:
                cell.textLabel.text = @"Get objects by IDs";
                break;
            case 2:
                cell.textLabel.text = @"Get objects";
                break;
            case 3:
                cell.textLabel.text = @"Count of objects";
                break;
            case 4:
                cell.textLabel.text = @"Create object";
                break;
            case 5:
                cell.textLabel.text = @"Create objects";
                break;
            case 6:
                cell.textLabel.text = @"Update object";
                break;
            case 7:
                cell.textLabel.text = @"Update objects";
                break;
            case 8:
                cell.textLabel.text = @"Delete object by ID";
                break;
            case 9:
                cell.textLabel.text = @"Delete objects by IDs";
                break;
            default:
                break;
        }
        
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Get permissions for object by ID";
                break;
            case 1:
                cell.textLabel.text = @"Update permissions";
                break;
            case 2:
                cell.textLabel.text = @"Create object with permissions";
                break;
            default:
                break;
        }
        
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Upload file";
                break;
            case 1:
                cell.textLabel.text = @"Download file";
                break;
            case 2:
                cell.textLabel.text = @"Delete file";
                break;
            default:
                break;
        }
    }
    
    return cell;
}

@end
