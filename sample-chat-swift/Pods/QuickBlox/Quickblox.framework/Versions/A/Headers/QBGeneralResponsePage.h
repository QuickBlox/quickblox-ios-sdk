//
//  QBLGeoDataResponsePage.h
//  Quickblox
//
//  Created by Andrey Moskvin on 4/28/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBGeneralResponsePage : NSObject

@property (nonatomic, readonly) NSUInteger totalEntries;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger perPage;

+ (QB_NONNULL instancetype)responsePageWithCurrentPage:(NSUInteger)currentPage
                                    perPage:(NSUInteger)perPage
                               totalEntries:(NSUInteger)totalEntries;
+ (QB_NONNULL instancetype)responsePageWithCurrentPage:(NSUInteger)currentPage perPage:(NSUInteger)perPage;

@end
