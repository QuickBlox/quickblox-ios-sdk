//
//  SessionSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "SessionSettingsViewController.h"
#import "UsersDataSourceProtocol.h"
#import "Settings.h"
#import "AudioSettingsViewController.h"
#import "VideoSettingsViewController.h"
#import "StunSettingsViewController.h"
#import "CallSettingsViewController.h"
#import "SampleCore.h"

@interface SessionSettingsViewController()

@property(weak, nonatomic) Settings *settings;

@property(weak, nonatomic) IBOutlet UILabel *build;
@property(weak, nonatomic) IBOutlet UILabel *version;
@property(weak, nonatomic) IBOutlet UILabel *revision;

@end

typedef NS_ENUM(NSUInteger, SessionConfigureItem) {
	
    SessionConfigureItemVideo,
    SessionConfigureItemAudio,
    SessionConfigureItemStunServer,
	SessionConfigureItemCallSettings,
};

@implementation SessionSettingsViewController

- (void)loadView {
	[super loadView];
	_settings = [SampleCore settings];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

	self.build.text = [NSString stringWithFormat:@"Build %@", build];
	self.version.text = [NSString stringWithFormat:@"Version %@", version];
	self.revision.text = [NSString stringWithFormat:@"QuickbloxWebRTC v%@ webrtc rev %@",QuickbloxWebRTCFrameworkVersion, QuickbloxWebRTCRevision];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)pressDoneBtn:(id)sender {
    
    [[SampleCore settings] saveToDisk];
    [self applyConfiguration];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyConfiguration {
    
    NSMutableArray *iceServers = [NSMutableArray array];
    
    for (NSString *url in [SampleCore settings].stunServers) {
        
        QBRTCICEServer *server = [QBRTCICEServer serverWithURL:url username:@"" password:@""];
        [iceServers addObject:server];
    }
    
    [iceServers addObjectsFromArray:[self quickbloxICE]];
    
    [QBRTCConfig setICEServers:iceServers];
    [SampleCore settings].mediaConfiguration.videoCodec = QBRTCVideoCodecH264;
    [QBRTCConfig setMediaStreamConfiguration:[SampleCore settings].mediaConfiguration];
    [QBRTCConfig setStatsReportTimeInterval:1.f];
}

- (NSArray *)quickbloxICE {
    
    NSString *password = @"baccb97ba2d92d71e26eb9886da5f1e0";
    NSString *userName = @"quickblox";
    
    NSArray *urls = @[
                      @"turn.quickblox.com",       //USA
                      @"turnsingapore.quickblox.com",   //Singapore
                      @"turnireland.quickblox.com"      //Ireland
                      ];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:urls.count];
    
    for (NSString *url in urls) {
        
        QBRTCICEServer *stunServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"stun:%@", url]
                                                          username:@""
                                                          password:@""];
        
        
        QBRTCICEServer *turnUDPServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"turn:%@:3478?transport=udp", url]
                                                             username:userName
                                                             password:password];
        
        QBRTCICEServer *turnTCPServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"turn:%@:3478?transport=tcp", url]
                                                             username:userName
                                                             password:password];
        
        [result addObjectsFromArray:@[stunServer, turnTCPServer, turnUDPServer]];
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self detailTextForRowAtIndexPath:indexPath];
    
    return cell;
}

- (NSString *)detailTextForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (indexPath.row == SessionConfigureItemVideo) {
        
        return [NSString stringWithFormat:@"%tux%tu", self.settings.videoFormat.width, self.settings.videoFormat.height];
        
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
    else if (indexPath.row == SessionConfigureItemStunServer) {
        
        NSString *selected = [NSString stringWithFormat:@"Selected - %zd", [SampleCore settings].stunServers.count];
        return selected;
	}
    else if (indexPath.row == SessionConfigureItemCallSettings) {
        
		return @""; // nothing to show
	}
		
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	BaseSettingsController *VC = nil;
	if (indexPath.row == SessionConfigureItemStunServer) {
        
		VC = [[StunSettingsViewController alloc] init];
	}
    else if (indexPath.row == SessionConfigureItemVideo) {
		VC = [[VideoSettingsViewController alloc] init];
	}
    else if (indexPath.row == SessionConfigureItemAudio) {
		VC = [[AudioSettingsViewController alloc] init];
	}
    else if( indexPath.row == SessionConfigureItemCallSettings) {
		VC = [[CallSettingsViewController alloc] init];
	}
    
	[self.navigationController pushViewController:VC animated:YES];
	
}

@end
