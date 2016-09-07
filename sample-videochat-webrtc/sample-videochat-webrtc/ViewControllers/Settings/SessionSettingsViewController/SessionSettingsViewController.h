//
//  SessionSettingsViewController.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SessionSettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender;

@end

@interface SessionSettingsViewController : UITableViewController

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;

@end
