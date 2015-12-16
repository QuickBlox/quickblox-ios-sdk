//
//  AudioSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "AudioSettingsViewController.h"
#import "Settings.h"

@interface AudioSettingsViewController ()

@property (copy, nonatomic) NSIndexPath *audioCodecIndexPath;
@property (strong, nonatomic) Settings *settings;

@end

@implementation AudioSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = [Settings instance];
    self.audioCodecIndexPath = [NSIndexPath indexPathForRow:self.settings.mediaConfiguration.audioCodec inSection:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =  [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    void (^checkmakr)(BOOL) = ^(BOOL isCheckmark){
        
        if (isCheckmark) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    };
    
    if (indexPath.section == 0) {
        
        checkmakr([indexPath compare:self.audioCodecIndexPath] == NSOrderedSame);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        self.audioCodecIndexPath = indexPath;
        
        self.settings.mediaConfiguration.audioCodec = indexPath.row;
    }
    
    [tableView reloadData];
}

@end
