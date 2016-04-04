//
//  STKStickersSettingsViewController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersSettingsViewController.h"
#import "STKStickersEntityService.h"
#import "STKStickersApiService.h"
#import "STKTableViewDataSource.h"
#import "STKStickerPackObject.h"
#import "STKUtility.h"
#import "STKStickerSettingsCell.h"

#import "STKStickersShopViewController.h"
#import "STKStickersConstants.h"


@interface STKStickersSettingsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) STKStickersEntityService *service;
@property (strong, nonatomic) STKStickersApiService *apiService;
@property (strong, nonatomic) STKTableViewDataSource *dataSource;
@property (strong, nonatomic) UIBarButtonItem *editBarButton;

@end

@implementation STKStickersSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STKStickerSettingsCell" bundle:nil] forCellReuseIdentifier:@"STKStickerSettingsCell"];
    
    
    self.dataSource = [[STKTableViewDataSource alloc] initWithItems:nil cellIdentifier:@"STKStickerSettingsCell" configureBlock:^(STKStickerSettingsCell *cell, STKStickerPackObject *item) {
        [cell configureWithStickerPack:item];
    }];
    
    self.service = [STKStickersEntityService new];
    self.apiService = [STKStickersApiService new];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    
    self.navigationItem.title = @"Stickers";
    
    [self setUpButtons];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
    self.navigationController.navigationBar.translucent = NO;
    
    __weak typeof(self) wself = self;
    
    self.dataSource.deleteBlock = ^(NSIndexPath *indexPath,STKStickerPackObject* item) {
        [wself.apiService deleteStickerPackWithName:item.packName success:^(id response) {
            [wself.service togglePackDisabling:item];
            [wself updateStickerPacks];
        } failure:^(NSError *error) {
            
        }];
    };
    
    self.dataSource.moveBlock = ^(NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath) {
        
        [wself reorderPacks];
    };
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateStickerPacks];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void) setUpButtons {
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButton;
    
    self.editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
    
    self.navigationItem.rightBarButtonItem = self.editBarButton;
    
}

- (void) reorderPacks {
    NSMutableArray *dataSoruce = [self.dataSource dataSource];
    [dataSoruce enumerateObjectsUsingBlock:^(STKStickerPackObject* obj, NSUInteger idx, BOOL *stop) {
        obj.order = @(idx);
    }];
    NSArray *reorderedPacks = [NSArray arrayWithArray:dataSoruce];
    self.service.stickersArray = reorderedPacks;
    [self.service saveStickerPacks:reorderedPacks];
}

- (void) updateStickerPacks {
    __weak typeof(self) wself = self;
    
    [self.service getStickerPacksIgnoringRecentWithType:nil completion:^(NSArray *stickerPacks) {
        [wself.dataSource setDataSourceArray:stickerPacks];
        [wself.tableView reloadData];
    } failure:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerPackObject *stickerPack = [self.dataSource itemAtIndexPath:indexPath];
    
    STKStickersShopViewController *shopViewController = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:nil];
    shopViewController.packName = stickerPack.packName;
    [self.navigationController pushViewController:shopViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Actions

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.editBarButton.title = (self.tableView.editing) ? @"Done" : @"Edit";
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
//        [[NSNotificationCenter defaultCenter]postNotificationName:STKStickersReorderStickersNotification object:self];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:STKStickersReorderStickersNotification object:self userInfo:@{@"packs": self.dataSource.dataSource}];
        [[NSNotificationCenter defaultCenter] postNotificationName:STKCloseModalViewNotification object:self];
    }];
}


@end
