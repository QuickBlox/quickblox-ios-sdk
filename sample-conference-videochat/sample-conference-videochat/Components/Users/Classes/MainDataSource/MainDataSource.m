//
//  MainDataSource.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "MainDataSource.h"

@interface MainDataSource () {
    
    SEL _sortSelector;
}

@property (nonatomic, readwrite) NSArray *selectedObjects;

@end

@implementation MainDataSource

// MARK: Construction

- (instancetype)initWithSortSelector:(SEL)sortSelector {
    
    self = [super init];
    if (self != nil) {
        
        _sortSelector = sortSelector;
        _objects = [[NSArray alloc] init];
        _selectedObjects = [[NSArray alloc] init];
    }
    
    return self;
}

// MARK: Public

- (void)setObjects:(NSArray *)objects {
    
    if (![_objects isEqualToArray:objects]) {
        
        _objects = [self sortObjects:objects];
        
        NSMutableArray *mutableSelectedObjects = [_selectedObjects mutableCopy];
        for (id obj in self.selectedObjects) {
            
            if (![_objects containsObject:obj]) {
                [mutableSelectedObjects removeObject:obj];
            }
        }
        _selectedObjects = [mutableSelectedObjects copy];
    }
}

- (NSArray *)selectedObjects {
    return [_selectedObjects copy];
}

- (void)selectObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = _objects[indexPath.row];
    
    NSMutableArray *mutableSelectedObjects = [_selectedObjects mutableCopy];
    if ([_selectedObjects containsObject:obj]) {
        [mutableSelectedObjects removeObject:obj];
    }
    else {
        [mutableSelectedObjects addObject:obj];
    }
    _selectedObjects = [mutableSelectedObjects copy];
}

- (void)deselectAllObjects {
    _selectedObjects = [[NSArray alloc] init];
}

// MARK: Private

- (NSArray *)sortObjects:(NSArray *)objects {
    
    // Create sort Descriptor
    NSSortDescriptor *objectsSortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(_sortSelector)
                                ascending:NO];
    
    NSArray *sortedObjects = [objects sortedArrayUsingDescriptors:@[objectsSortDescriptor]];
    
    return sortedObjects;
}

// MARK: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(nil, @"Required to be implemented by subclass.");
    return nil;
}

@end
