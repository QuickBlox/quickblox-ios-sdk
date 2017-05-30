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
#import "RecordSettings.h"

@interface SessionSettingsViewController()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) Settings *settings;

@end

typedef NS_ENUM(NSUInteger, SessionConfigureItem) {
    
    SessionConfigureItemVideo,
    SessionConfigureItemAudio,
    SessionConfigureItemRecord
};

@implementation SessionSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = [Settings instance];
    
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
    
    [self.settings saveToDisk];
    [self.settings applyConfig];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        && indexPath.row == SessionConfigureItemRecord
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
    
    if (indexPath.row == SessionConfigureItemRecord) {
        if ([UIDevice currentDevice].qbrtc_lowPerformance) {
            return @"unavailable";
        }
        else {
            return self.settings.recordSettings.isEnabled ? @"On" : @"Off";
        }
    }
    else if (indexPath.row == SessionConfigureItemVideo) {
        
#if !(TARGET_IPHONE_SIMULATOR)
        return [NSString stringWithFormat:@"%tux%tu", self.settings.videoFormat.width, self.settings.videoFormat.height];
#else
        return @"unavailable";
#endif
        
    }
    else if (indexPath.row == SessionConfigureItemAudio) {
        
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
