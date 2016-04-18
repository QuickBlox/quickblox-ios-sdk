//
//  SessionSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "SessionSettingsViewController.h"
#import "UsersDataSource.h"
#import "Settings.h"

@interface SessionSettingsViewController()

@property(strong, nonatomic) Settings *settings;

@end

typedef NS_ENUM(NSUInteger, SessionConfigureItem) {
    
    SessionConfigureItemVideo,
    SessionConfigureItemAuido,
    SessionConfigureItemListOfUsers,
    SessionConfigureItemStunServer
};

@implementation SessionSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = Settings.instance;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)pressDoneBtn:(id)sender {
    
    [Settings.instance saveToDisk];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self detailTextForRowAtIndexPaht:indexPath];
    
    return cell;
}

- (NSString *)detailTextForRowAtIndexPaht:(NSIndexPath *)indexPath {

    
    if (indexPath.row == SessionConfigureItemVideo) {
        
        return [NSString stringWithFormat:@"%tux%tu", self.settings.videoFormat.width, self.settings.videoFormat.height];
        
    }
    else if (indexPath.row == SessionConfigureItemAuido) {
        
        if (self.settings.mediaConfiguration.audioCodec == QBRTCAudioCodecOpus ) {
            
            return @"Opus";
        }
        else if (self.settings.mediaConfiguration.audioCodec == QBRTCAudioCodecISAC) {
            
            return @"ISAC";
        }
        else if (self.settings.mediaConfiguration.audioCodec == QBRTCAudioCodeciLBC) {
            
            return @"iLBC";
        }
        
    }
    else if (indexPath.row == SessionConfigureItemListOfUsers) {
        
        return [UsersDataSource.instance strWithList:Settings.instance.listType];
    }
    else if (indexPath.row == SessionConfigureItemStunServer) {
        
        NSString *selected = [NSString stringWithFormat:@"Selected - %lu", (unsigned long)Settings.instance.stunServers.count];
        return selected;
    }
    
    return @"Unknown";
}

@end
