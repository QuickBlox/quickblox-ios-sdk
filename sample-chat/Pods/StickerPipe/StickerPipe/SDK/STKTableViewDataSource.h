//
//  STKTableViewDataSource.h
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^TableViewCellConfigureBlock)(id cell, id item);
typedef void (^TableViewDeleteItemBlock)(NSIndexPath *indexPath,id item);
typedef void (^TableViewMoveItemBlock)(NSIndexPath *fromIndexPath,NSIndexPath *toIndexPath);

@interface STKTableViewDataSource : NSObject <UITableViewDataSource>

@property (copy, nonatomic) TableViewDeleteItemBlock deleteBlock;

@property (copy, nonatomic) TableViewMoveItemBlock moveBlock;

@property (strong, nonatomic, readonly) NSMutableArray *dataSource;

- (instancetype)initWithItems:(NSArray*)items
        cellIdentifier:(NSString*)identifier
        configureBlock:(TableViewCellConfigureBlock)configureBlock;

- (id)itemAtIndexPath:(NSIndexPath*)indexPath;

- (void)setDataSourceArray:(NSArray*)array;

@end
