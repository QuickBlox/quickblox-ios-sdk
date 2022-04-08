//
//  InfoTableViewController.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "InfoTableViewController.h"
#import "InfoModel.h"
#import "InfoTableViewCell.h"
#import <Quickblox/Quickblox.h>

NSString *const kInfoTableViewCellId = @"InfoTableViewCell";
NSString *const kLogoTableViewCellId = @"QBLogoTableViewCell";


@interface InfoTableViewController ()
@property (strong, nonatomic) NSMutableArray<InfoModel*>* infoModels;
@end

@implementation InfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    [self setupTableView];
}

- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTableView {
    self.infoModels = [NSMutableArray new];
    
    NSString *appName = NSBundle.mainBundle.infoDictionary[@"CFBundleName"];
    InfoModel *appNameModel = [[InfoModel alloc] init];
    appNameModel.title = @"Application version";
    appNameModel.info = [NSString stringWithFormat:@"%@", appName];
    [self.infoModels addObject:appNameModel];
    
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    InfoModel *appVersionModel = [[InfoModel alloc] init];
    appVersionModel.title = @"Application version";
    appVersionModel.info = [NSString stringWithFormat:@"%@", appVersion];
    [self.infoModels addObject:appVersionModel];
    
    InfoModel *quickBloxSdkVersionModel = [[InfoModel alloc] init];
    quickBloxSdkVersionModel.title = @"QuickBlox SDK version";
    quickBloxSdkVersionModel.info = [NSString stringWithFormat:@"%@", QuickbloxFrameworkVersion];
    [self.infoModels addObject:quickBloxSdkVersionModel];
    
    InfoModel *appIDModel = [[InfoModel alloc] init];
    appIDModel.title = @"Application ID";
    appIDModel.info = [NSString stringWithFormat:@"%@", @(QBSettings.applicationID)];
    [self.infoModels addObject:appIDModel];
    
    InfoModel *authKeyModel = [[InfoModel alloc] init];
    authKeyModel.title = @"Auhtorization key";
    authKeyModel.info = [NSString stringWithFormat:@"%@", QBSettings.authKey];
    [self.infoModels addObject:authKeyModel];
    
    InfoModel *authSecretModel = [[InfoModel alloc] init];
    authSecretModel.title = @"Auhtorization secret";
    authSecretModel.info = [NSString stringWithFormat:@"%@", QBSettings.authSecret];
    [self.infoModels addObject:authSecretModel];
    
    InfoModel *accountKeyModel = [[InfoModel alloc] init];
    accountKeyModel.title = @"Account key";
    accountKeyModel.info = [NSString stringWithFormat:@"%@", QBSettings.accountKey];
    [self.infoModels addObject:accountKeyModel];
    
    InfoModel *apiDomainModel = [[InfoModel alloc] init];
    apiDomainModel.title = @"API domain";
    apiDomainModel.info = [NSString stringWithFormat:@"%@", QBSettings.apiEndpoint];
    [self.infoModels addObject:apiDomainModel];
    
    InfoModel *chatDomainModel = [[InfoModel alloc] init];
    chatDomainModel.title = @"Chat domain";
    chatDomainModel.info = [NSString stringWithFormat:@"%@", QBSettings.chatEndpoint];
    [self.infoModels addObject:chatDomainModel];
    
    NSString *qaVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    InfoModel *qaVersionModel = [[InfoModel alloc] init];
    qaVersionModel.title = @"QA version";
    qaVersionModel.info = [NSString stringWithFormat:@"%@", qaVersion];
    [self.infoModels addObject:qaVersionModel];
    
    InfoModel *logoModel = [[InfoModel alloc] init];
    logoModel.title = @"logo";
    logoModel.info = @"logo";
    [self.infoModels addObject:logoModel];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isLast = indexPath.row == self.infoModels.count - 1;
    if (isLast) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kLogoTableViewCellId];
        return cell;
    }
    InfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kInfoTableViewCellId];
    InfoModel *model = self.infoModels[indexPath.row];
    [cell applyInfo:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isLast = indexPath.row == self.infoModels.count - 1;
    return isLast ? 80.0f : 54.0f;
}

@end
