//
//  QBRScoreDeleteQuery.h
//  RatingsService
//
//  Created by Alexander Chaika on 06.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRScoreDeleteQuery : QBRScoreQuery {
    NSUInteger scoreId;
}
@property (nonatomic, readonly) NSUInteger scoreId;

-(id)initWithScoreId:(NSUInteger)_scoreId;

@end
