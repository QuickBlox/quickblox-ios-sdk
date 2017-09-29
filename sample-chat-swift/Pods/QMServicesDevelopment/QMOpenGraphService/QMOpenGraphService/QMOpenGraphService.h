//
//  QMOpenGraphService.h
//  QMOpenGraphService
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMOpenGraphMemoryStorage.h"
#import "QMOpenGraphItem.h"
#import "QMBaseService.h"
#import <UIKit/UIKit.h>

@protocol QMOpenGraphServiceDelegate;
@protocol QMOpenGraphCacheDataSource;

NS_ASSUME_NONNULL_BEGIN

@interface QMOpenGraphService : QMBaseService

/**
 Memory storage for QMLinkPreview
 */
@property (nonatomic, readonly) QMOpenGraphMemoryStorage *memoryStorage;

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMOpenGraphCacheDataSource>)cacheDataSource NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/**
 *  Add instance that confirms Open Graph service multicaste protocol.
 *
 *  @param delegate instance that confirms id<QMOpenGraphServiceDelegate> protocol
 */
- (void)addDelegate:(id <QMOpenGraphServiceDelegate>)delegate;

/**
 *  Remove instance that confirms Open Graph service multicaste protocol.
 *
 *  @param delegate instance that confirms id<QMOpenGraphServiceDelegate> protocol
 */
- (void)removeDelegate:(id <QMOpenGraphServiceDelegate>)delegate;

/**
 Method returns cached instance of QMOpenGraphItem class
 
 @param ID Identifier
 */
- (void)preloadGraphItemForText:(NSString *)text ID:(NSString *)ID;

- (void)cancelAllloads;

@end

@protocol QMOpenGraphServiceDelegate <NSObject>

@optional
/**
 Called if ..
 
 @param openGraphSerivce Open graph serivce
 @param openGraphItem QMOpenGraphItem instance
 */
- (void)openGraphSerivce:(QMOpenGraphService *)openGraphSerivce
didAddOpenGraphItemToMemoryStorage:(QMOpenGraphItem *)openGraphItem;

- (void)openGraphSerivce:(QMOpenGraphService *)openGraphSerivce
           hasFaviconURL:(NSURL *)url
              completion:(dispatch_block_t)completion;

- (void)openGraphSerivce:(QMOpenGraphService *)openGraphSerivce
             hasImageURL:(NSURL *)url
              completion:(dispatch_block_t)completion;

- (void)openGraphSerivce:(QMOpenGraphService *)openGraphSerivce
        didLoadFromCache:(QMOpenGraphItem *)openGraph;
@end

@protocol QMOpenGraphCacheDataSource <NSObject>

@optional
- (nullable QMOpenGraphItem *)cachedOpenGraphItemWithID:(NSString *)ID;

@end

NS_ASSUME_NONNULL_END
