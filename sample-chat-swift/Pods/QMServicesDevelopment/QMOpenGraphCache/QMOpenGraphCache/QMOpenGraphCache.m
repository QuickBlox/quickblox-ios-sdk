//
//  QMOpenGraphCache.m
//  QMOpenGraphCache
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMOpenGraphCache.h"
#import "QMOpenGraphModelIncludes.h"

@implementation QMOpenGraphCache

static QMOpenGraphCache *_openGraphCache = nil;

+ (QMOpenGraphCache *)instance {
    
    NSAssert(_openGraphCache, @"You must first perform @selector(setupDBWithStoreNamed:)");
    return _openGraphCache;
}

//MARK: - Configure store

+ (void)setupDBWithStoreNamed:(NSString *)storeName
   applicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    NSManagedObjectModel *model =
    [NSManagedObjectModel QM_newModelNamed:@"QMOpenGraphModel.momd"
                             inBundleNamed:@"QMOpenGraphCacheModel.bundle"
                                 fromClass:[self class]];
    
    NSParameterAssert(!_openGraphCache);
    _openGraphCache = [[QMOpenGraphCache alloc] initWithStoreNamed:storeName
                                                             model:model
                                        applicationGroupIdentifier:appGroupIdentifier];
}

//MARK: - Fetch link previews
- (nullable QMOpenGraphItem *)openGrapItemWithID:(NSString *)ID {
    
    __block QMOpenGraphItem *result = nil;
    [self performMainQueue:^(NSManagedObjectContext *ctx) {
        result = [[CDOpenGraphModel QM_findFirstByAttribute:@"id"
                                               withValue:ID
                                               inContext:ctx] toQMOpenGraphItem];
    }];
    
    return result;
}

- (void)deleteAllOpenGraphItemsWithCompletion:(dispatch_block_t)completion {
    
    [self save:^(NSManagedObjectContext *ctx) {
        
        [CDOpenGraphModel QM_truncateAllInContext:ctx];
        
    } finish:completion];
}

//MARK: - Insert / Update
- (void)insertOrUpdateOpenGraphItem:(QMOpenGraphItem *)og
                       completion:(dispatch_block_t)completion {
    
    [self save:^(NSManagedObjectContext *ctx) {
        
        CDOpenGraphModel *cachedOgItem =
        [CDOpenGraphModel QM_findFirstOrCreateByAttribute:@"id"
                                             withValue:og.ID
                                             inContext:ctx];
        
        [cachedOgItem updateWithQMOpenGraphItem:og];
        
    } finish:completion];
}

@end
