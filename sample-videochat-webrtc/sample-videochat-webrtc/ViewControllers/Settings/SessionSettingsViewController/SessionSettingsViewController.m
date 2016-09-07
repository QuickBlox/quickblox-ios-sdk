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

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property(strong, nonatomic) Settings *settings;

@end

typedef NS_ENUM(NSUInteger, SessionConfigureItem) {
    
    SessionConfigureItemVideo,
    SessionConfigureItemAuido,
};

@implementation SessionSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = Settings.instance;
    
    //QuickBlox WebRTC Build 265. Version 1.4
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *appBuild = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:
                         @"Sample version %@ build %@.\n"
                         "QuickBlox WebRTC SDK: %@ Revision %@",
                         appVersion, appBuild,
                         QuickbloxWebRTCFrameworkVersion, QuickbloxWebRTCRevision];
    
    self.versionLabel.text = version;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:@"LogoutCell"]) {
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"Logout ?", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self.delegate settingsViewController:self didPressLogout:cell];
                                    }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
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
    
    return @"Unknown";
}

@end
