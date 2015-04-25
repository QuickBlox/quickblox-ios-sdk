//
//  StunViewController.m
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 07.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "StunViewController.h"
#import "SVProgressHUD.h"

@interface StunViewController ()

@property (strong, nonatomic) NSDictionary *collection;
@property (strong, nonatomic) NSArray *titles;

@end

@implementation StunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadStunServers];

}

- (void)loadStunServers {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"STUNDatasource"
                                                          ofType:@"plist"];
    
    self.collection = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    self.titles = self.collection.allKeys;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *key = self.titles[indexPath.row];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = self.collection[key];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = self.titles[indexPath.row];
    NSURL *url = [NSURL URLWithString:self.collection[key]];
    QBICEServer *iceServer = [QBICEServer serverWithURL:url username:@"" password:@""];
    [QBRTCConfig setICEServers:@[iceServer]];
    
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Set %@", key]];
}

- (IBAction)pressDoneNavItem:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
