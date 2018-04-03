//
//  DialogsDataSource.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "DialogsDataSource.h"

#import <Quickblox/Quickblox.h>
#import "DialogTableViewCell.h"
#import "SVProgressHUD.h"
#import "QBCore.h"

@interface DialogsDataSource () <DialogTableViewCellDelegate>

@end

@implementation DialogsDataSource

// MARK: Construction

+ (instancetype)dialogsDataSource {
    return [[self alloc] initWithSortSelector:@selector(createdAt)];
}

// MARK: UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DialogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DialogTableViewCell"];
    
    QBChatDialog *chatDialog = self.objects[indexPath.row];
    
    [cell setTitle:chatDialog.name];
    cell.delegate = self;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *str = @"Select chat dialog to join conference into";
    
    return NSLocalizedString(str, nil);
}

- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate dialogsDataSource:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

// MARK: - DialogTableViewCellDelegate

- (void)dialogCellDidListenerButton:(DialogTableViewCell *)dialogCell {
    [_delegate dialogsDataSource:self dialogCellDidTapListener:dialogCell];
}

- (void)dialogCellDidAudioButton:(DialogTableViewCell *)dialogCell {
    [_delegate dialogsDataSource:self dialogCellDidTapAudio:dialogCell];
}

- (void)dialogCellDidVideoButton:(DialogTableViewCell *)dialogCell {
    [_delegate dialogsDataSource:self dialogCellDidTapVideo:dialogCell];
}

@end
