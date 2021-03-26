//
//  QBGeneralResponsePage.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBGeneralResponsePage : NSObject

@property (nonatomic, assign, readonly) NSUInteger totalEntries;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger perPage;

+ (instancetype)responsePageWithCurrentPage:(NSUInteger)currentPage
                                    perPage:(NSUInteger)perPage
                               totalEntries:(NSUInteger)totalEntries;
+ (instancetype)responsePageWithCurrentPage:(NSUInteger)currentPage perPage:(NSUInteger)perPage;

@end

NS_ASSUME_NONNULL_END
