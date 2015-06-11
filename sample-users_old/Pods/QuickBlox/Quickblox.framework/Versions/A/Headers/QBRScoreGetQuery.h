//
//  QBRScoreGetQuery.h
//  RatingsService
//
//  Created by Alexander Chaika on 02.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRScoreQuery.h"

@class QBRScoreGetRequest;

@interface QBRScoreGetQuery : QBRScoreQuery {
    NSUInteger scoreId;
    NSUInteger userId;
    
    NSInteger topN;
    NSUInteger gameModeId;
    
    QBRScoreGetRequest *additionalRequest;
}
@property (nonatomic, readonly) NSUInteger scoreId;
@property (nonatomic, readonly) NSUInteger userId;
@property (nonatomic, readonly) NSInteger topN;
@property (nonatomic, readonly) NSUInteger gameModeId;
@property (nonatomic, readonly) QBRScoreGetRequest *additionalRequest;

-(id)initWithScoreId:(NSUInteger)_scoreId;
-(id)initWithUserId:(NSUInteger)_userId extendedRequest:(QBRScoreGetRequest *)extendedRequest;
-(id)initWithTopN:(NSInteger)_topN gameModeId:(NSInteger)_gameModeId extendedRequest:(QBRScoreGetRequest *)extendedRequest;

@end
