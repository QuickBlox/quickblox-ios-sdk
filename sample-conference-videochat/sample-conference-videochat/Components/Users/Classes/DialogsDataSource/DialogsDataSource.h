//
//  DialogsDataSource.h
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "MainDataSource.h"

@class QBChatDialog;
@class DialogsDataSource;

NS_ASSUME_NONNULL_BEGIN

@protocol DialogsDataSourceDelegate <NSObject>

- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource dialogCellDidTapListener:(__kindof UITableViewCell *)dialogCell;
- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource dialogCellDidTapAudio:(__kindof UITableViewCell *)dialogCell;
- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource dialogCellDidTapVideo:(__kindof UITableViewCell *)dialogCell;
- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DialogsDataSource : MainDataSource<QBChatDialog *>

@property (weak, nonatomic, nullable) id<DialogsDataSourceDelegate> delegate;

+ (instancetype)dialogsDataSource;

@end

NS_ASSUME_NONNULL_END
