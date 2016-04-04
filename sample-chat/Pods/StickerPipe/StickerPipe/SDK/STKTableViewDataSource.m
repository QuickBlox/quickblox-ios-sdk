//
//  STKTableViewDataSource.m
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKTableViewDataSource.h"

@interface STKTableViewDataSource ()

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (copy, nonatomic) TableViewCellConfigureBlock configureBlock;
@property (strong, nonatomic) NSString *cellIdentifier;

@end

@implementation STKTableViewDataSource

- (instancetype)initWithItems:(NSArray *)items cellIdentifier:(NSString *)identifier configureBlock:(TableViewCellConfigureBlock)configureBlock
{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray arrayWithArray:items];
        self.cellIdentifier = identifier;
        self.configureBlock = configureBlock;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureBlock(cell, item);
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    id object = self.dataSource[sourceIndexPath.row];
    [self.dataSource removeObjectAtIndex:sourceIndexPath.row];
    [self.dataSource insertObject:object atIndex:destinationIndexPath.row];
    self.moveBlock(sourceIndexPath, destinationIndexPath);
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.deleteBlock(indexPath ,self.dataSource[indexPath.row]);
        
    }
}

#pragma mark - Common

- (void)setDataSourceArray:(NSArray *)dataSource {
    self.dataSource = [NSMutableArray arrayWithArray:dataSource];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.dataSource[indexPath.row];
}

@end
