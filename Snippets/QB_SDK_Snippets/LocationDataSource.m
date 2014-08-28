//
//  LocationDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "LocationDataSource.h"

@implementation LocationDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 6;
    }
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"GeoData";
    }
    
    return @"Places";
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // GeoData
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create GeoData";
                    break;
                case 1:
                    cell.textLabel.text = @"Get GeoData with ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Get multiple GeoData";
                    break;
                case 3:
                    cell.textLabel.text = @"Update GeoData";
                    break;
                case 4:
                    cell.textLabel.text = @"Delete GeoData with ID";
                    break;
                case 5:
                    cell.textLabel.text = @"Delete multiple GeoData";
                    break;
            }
            
            break;
            
            // Places
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create Place";
                    break;
                case 1:
                    cell.textLabel.text = @"Get Places";
                    break;
                case 2:
                    cell.textLabel.text = @"Get Place with ID";
                    break;
                case 3:
                    cell.textLabel.text = @"Update Place";
                    break;
                case 4:
                    cell.textLabel.text = @"Delete Place with ID";
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
