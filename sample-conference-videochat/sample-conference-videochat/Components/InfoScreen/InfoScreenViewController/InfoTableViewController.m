//
//  InfoTableViewController.m
//  sample-conference-videochat
//
//  Created by Vladimir Nybozhinsky on 12/30/18.
//  Copyright © 2018 Quickblox. All rights reserved.
//

#import "InfoTableViewController.h"
#import "InfoModel.h"
#import "InfoTableViewCell.h"
#import <Quickblox/QBASession.h>

NSString *const kInfoTableViewCellId = @"InfoTableViewCell";
NSString *const kLogoTableViewCellId = @"QBLogoTableViewCell";


@interface InfoTableViewController ()
{
    NSMutableArray<InfoModel*>* infoModels;
}

@end

@implementation InfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
}

- (void)setupTableView
{
    infoModels = [NSMutableArray new];
    
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    InfoModel *appVersionModel = [[InfoModel alloc] init];
    appVersionModel.title = @"Application version:";
    appVersionModel.info = [NSString stringWithFormat:@"%@", appVersion];
    [infoModels addObject:appVersionModel];
    
    InfoModel *quickBloxSdkVersionModel = [[InfoModel alloc] init];
    quickBloxSdkVersionModel.title = @"QuickBlox SDK version:";
    quickBloxSdkVersionModel.info = [NSString stringWithFormat:@"%@", QuickbloxFrameworkVersion];
    [infoModels addObject:quickBloxSdkVersionModel];
    
    InfoModel *wbrtcVersionModel = [[InfoModel alloc] init];
    wbrtcVersionModel.title = @"QuickbloxWebRTC version:";
    wbrtcVersionModel.info = [NSString stringWithFormat:@"%@", QuickbloxWebRTCFrameworkVersion];
    [infoModels addObject:wbrtcVersionModel];
    
    InfoModel *appIDModel = [[InfoModel alloc] init];
    appIDModel.title = @"Application ID:";
    appIDModel.info = [NSString stringWithFormat:@"%lu", (unsigned long)QBSettings.applicationID];
    [infoModels addObject:appIDModel];
    
    InfoModel *authKeyModel = [[InfoModel alloc] init];
    authKeyModel.title = @"Auhtorization key:";
    authKeyModel.info = [NSString stringWithFormat:@"%@", QBSettings.authKey];
    [infoModels addObject:authKeyModel];
    
    InfoModel *authSecretModel = [[InfoModel alloc] init];
    authSecretModel.title = @"Auhtorization secret:";
    authSecretModel.info = [NSString stringWithFormat:@"%@", QBSettings.authSecret];
    [infoModels addObject:authSecretModel];
    
    InfoModel *accountKeyModel = [[InfoModel alloc] init];
    accountKeyModel.title = @"Account key:";
    accountKeyModel.info = [NSString stringWithFormat:@"%@", QBSettings.accountKey];
    [infoModels addObject:accountKeyModel];
    
    InfoModel *apiDomainModel = [[InfoModel alloc] init];
    apiDomainModel.title = @"API domain:";
    apiDomainModel.info = [NSString stringWithFormat:@"%@", QBSettings.apiEndpoint];
    [infoModels addObject:apiDomainModel];
    
    InfoModel *chatDomainModel = [[InfoModel alloc] init];
    chatDomainModel.title = @"API domain:";
    chatDomainModel.info = [NSString stringWithFormat:@"%@", QBSettings.chatEndpoint];
    [infoModels addObject:chatDomainModel];
    
    InfoModel *janusServerURLModel = [[InfoModel alloc] init];
    janusServerURLModel.title = @"API domain:";
    janusServerURLModel.info = [NSString stringWithFormat:@"%@", QBRTCConfig.conferenceEndpoint];
    [infoModels addObject:janusServerURLModel];
    
    InfoModel *logoModel = [[InfoModel alloc] init];
    logoModel.title = @"logo";
    logoModel.info = @"logo";
    [infoModels addObject:logoModel];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (infoModels.count > 0) {
        return infoModels.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = UITableViewCell.new;
    if (indexPath.row != infoModels.count - 1) {
        InfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kInfoTableViewCellId];
        InfoModel *model = infoModels[indexPath.row];
        [cell applyInfo:model];
        return cell;
    } else if (indexPath.row == infoModels.count - 1) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kLogoTableViewCellId];
        return cell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 54.0f;
    if (indexPath.row == infoModels.count - 1) {
        return 80.0f;
    }
    return cellHeight;
}

@end
