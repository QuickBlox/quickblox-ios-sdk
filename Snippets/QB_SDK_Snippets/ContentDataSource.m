//
//  ContentModuleDataSource.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 8/17/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "ContentDataSource.h"

@implementation ContentDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 10;
        case 1:
            return 3;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Blobs";
            
        case 1:
            return @"Tasks";
            
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
            // Blobs
        case 0:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create blob";
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"Get blob with ID";
                }
                    break;
                case 2:{
                    cell.textLabel.text = @"Get blobs";
                    break;
                }
                case 3:{
                    cell.textLabel.text = @"Get tagged blobs";
                }
                    break;
                case 4:{
                    cell.textLabel.text = @"Update blob";
                }
                    break;
                case 5:{
                    cell.textLabel.text = @"Delete blob with ID";
                }
                    break;
                case 6:{
                    cell.textLabel.text = @"Complete blob with ID";
                }
                    break;
                case 7:{
                    cell.textLabel.text = @"Get BlobObjectAccess with blob ID";
                }
                    break;
                case 8:{
                    cell.textLabel.text = @"Upload file";
                }
                    break;
                case 9:{
                    cell.textLabel.text = @"Download file with UID";
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
            // Tasks
        case 1:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"TUploadFile";
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"TDownloadFileWithBlobID";
                }
                    break;
                    
                case 2:{
                    cell.textLabel.text = @"TUpdateFileWithData";
                }
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
