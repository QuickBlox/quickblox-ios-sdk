//
//  QBRScorePagedAnswer.h
//  RatingsService
//
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedAnswer.h"

@class QBRScoreAnswer;

@interface QBRScorePagedAnswer : PagedAnswer{
	QBRScoreAnswer *scoreAnswer;
    
	NSMutableArray *scores;
}

@property (nonatomic, retain) NSMutableArray *scores;

@end
