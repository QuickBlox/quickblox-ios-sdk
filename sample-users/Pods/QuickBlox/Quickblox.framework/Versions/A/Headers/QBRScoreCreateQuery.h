//
//  QBRScoreCreateQuery.h
//  Quickblox
//
//  Created by Alexander Chaika on 02.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRScoreQuery.h"

@class QBRScore;

@interface QBRScoreCreateQuery : QBRScoreQuery {
	QBRScore *score;
}

@property (nonatomic, readonly) QBRScore *score;

-(id)initWithScore:(QBRScore *)_score;

@end
