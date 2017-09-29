//
//  QMOpenGraphMemoryStorage.h
//  QMOpenGraphService
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

@class QMOpenGraphItem;

NS_ASSUME_NONNULL_BEGIN

@interface QMOpenGraphMemoryStorage : NSObject <QMMemoryStorageProtocol>

- (nullable QMOpenGraphItem *)openGraphItemWithBaseURL:(NSString *)baseUrl;
- (nullable QMOpenGraphItem *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable QMOpenGraphItem *)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
