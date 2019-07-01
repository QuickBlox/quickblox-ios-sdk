//
//  SessionSettingsViewController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SessionSettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender;

@end

@interface SessionSettingsViewController : UITableViewController

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;

@end
