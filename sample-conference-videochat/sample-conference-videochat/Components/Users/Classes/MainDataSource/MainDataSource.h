//
//  MainDataSource.h
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainDataSource<__covariant ObjectType> : NSObject <UITableViewDataSource>

@property (nonatomic, copy) NSArray <ObjectType> *objects;
@property (nonatomic, readonly) NSArray <ObjectType> *selectedObjects;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithSortSelector:(SEL)sortSelector;

- (void)setObjects:(NSArray <ObjectType> *)objects;
- (void)selectObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAllObjects;

@end

NS_ASSUME_NONNULL_END
