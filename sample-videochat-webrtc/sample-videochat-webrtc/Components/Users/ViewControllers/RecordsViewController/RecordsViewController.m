//
//  RecordsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 28.02.17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import "RecordsViewController.h"
#import "FileManager.h"
@import AVKit;

@interface RecordsViewController ()

@property (strong, nonatomic) FileManager *fileManager;
@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic) AVPlayerViewController *playerViewController;

@end

@implementation RecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.fileManager = [FileManager instance];
    self.items = [self.fileManager listItemsInDirectoryAtPath:self.fileManager.documentsDirectory
                                                         deep:YES].mutableCopy;
    
    // add delete all button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Delete all"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(deleteAllRecords)];
}

- (void)deleteAllRecords {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Delete all items"
                                        message:NSLocalizedString(@"Are You Sure?", @"You shure?")
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               
                               for (NSString *path in self.items.copy) {
                                   
                                   BOOL success = [self.fileManager removeItemAtPath:path];
                                   if (success) {
                                       [self.items removeObject:path];
                                   }
                               }
                               
                               [self.tableView reloadData];
                           }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)playerPresented {
    return _playerViewController != nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordItemIdentifier"
                                                            forIndexPath:indexPath];
    NSString *path = self.items[indexPath.row];
    
    cell.textLabel.text = [path lastPathComponent];
    
    NSDictionary *attributtes = [self.fileManager attributesOfItemAtPath:path];
    
    NSDate *createDate = attributtes[NSFileCreationDate];
    cell.detailTextLabel.text = createDate.description;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"Delete item"
                                            message:NSLocalizedString(@"Are You Sure?", @"You shure?")
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                 style:UIAlertActionStyleCancel
                               handler:nil];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   
                                   NSString *path = self.items[indexPath.row];
                                   BOOL success = [self.fileManager removeItemAtPath:path];
                                   
                                   if (success) {
                                       
                                       [self.items removeObject:path];
                                       
                                       // Delete the row from the data source
                                       [tableView deleteRowsAtIndexPaths:@[indexPath]
                                                        withRowAnimation:UITableViewRowAnimationFade];
                                   }
                               }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    NSString *path = self.items[indexPath.row];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    
    playerViewController.player = [AVPlayer playerWithPlayerItem:item];
    [playerViewController.player play];
    
    [self presentViewController:playerViewController animated:YES completion:nil];
    _playerViewController = playerViewController;
}


@end
