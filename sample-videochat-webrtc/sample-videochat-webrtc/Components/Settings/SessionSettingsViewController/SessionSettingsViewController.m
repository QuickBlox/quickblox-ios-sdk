//
//  SessionSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SessionSettingsViewController.h"
#import "UsersDataSource.h"
#import "Settings.h"
#import "UsersViewController.h"

@interface SessionSettingsViewController()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

typedef NS_ENUM(NSUInteger, SessionConfigureItem) {
    
    SessionConfigureItemVideo,
    SessionConfigureItemAudio,
};

@implementation SessionSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self detailTextForRowAtIndexPaht:indexPath];
    
#if (TARGET_IPHONE_SIMULATOR)
    // make video setting cell unavailable for sims
    if (indexPath.row == SessionConfigureItemVideo
        && indexPath.section == 0) {
        cell.userInteractionEnabled = NO;
    }
#endif
    
    if ([UIDevice currentDevice].qbrtc_lowPerformance
        && indexPath.section == 0) {
        cell.userInteractionEnabled = NO;
    }
    
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

    Settings *settings = [[Settings alloc] init];
    if (indexPath.row == SessionConfigureItemVideo) {
        
#if !(TARGET_IPHONE_SIMULATOR)
        return [NSString stringWithFormat:@"%tux%tu", settings.videoFormat.width, settings.videoFormat.height];
#else
        return @"unavailable";
#endif
        
    }
    else if (indexPath.row == SessionConfigureItemAudio) {
        
        if (settings.mediaConfiguration.audioCodec == QBRTCAudioCodecOpus ) {
            
            return @"Opus";
        }
        else if (settings.mediaConfiguration.audioCodec == QBRTCAudioCodecISAC) {
            
            return @"ISAC";
        }
        else if (settings.mediaConfiguration.audioCodec == QBRTCAudioCodeciLBC) {
            
            return @"iLBC";
        }
        
    }
    
    return @"Unknown";
}

@end
