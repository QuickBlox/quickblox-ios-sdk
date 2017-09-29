//
//  QMOpenGraphCache.h
//  QMOpenGraphCache
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMDBStorage.h"
#import "QMOpenGraphItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMOpenGraphCache : QMDBStorage

@property (class, readonly) QMOpenGraphCache *instance;

/**
 Get Open Graph Item with url if exist

 @param ID key
 @return QMOpenGraphItem instance for
 */
- (nullable QMOpenGraphItem *)openGrapItemWithID:(NSString *)ID;

/**
 Insert or update openGraphItem
 @param openGraphItem QMOpenGraphItem instance
 @param completion completion block
 */
- (void)insertOrUpdateOpenGraphItem:(QMOpenGraphItem *)openGraphItem
                         completion:(nullable dispatch_block_t)completion;

/**
 Remove all Open Graph items from storage

 @param completion completion block
 */
- (void)deleteAllOpenGraphItemsWithCompletion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
