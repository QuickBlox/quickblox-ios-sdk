//
//  AuthModuleDataSoure.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "AuthDataSource.h"

@implementation AuthDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Session creation";
    }
    
    return @"Session destroy";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 4;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // Session creation
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create session";
                    break;
                case 1:
                    cell.textLabel.text = @"Create session with User";
                    break;
                case 2:
                    cell.textLabel.text = @"Create session with social provider";
                    break;
                case 3:
                    cell.textLabel.text = @"Create session with social access token";
                    break;
            }
            
            break;
            
            // Session destroy
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Destroy session";
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
