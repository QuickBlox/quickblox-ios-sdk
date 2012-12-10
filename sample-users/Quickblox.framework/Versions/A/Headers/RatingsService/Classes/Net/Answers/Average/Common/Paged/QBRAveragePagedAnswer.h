//
//  QBRAveragePagedAnswer.h
//  Quickblox
//
//  Created by Alexander Chaika on 05.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRAveragePagedAnswer : PagedAnswer{
	QBRAverageAnswer *averageAnswer;
	NSMutableArray *averages;
}

@property (nonatomic, retain) NSMutableArray *averages;

@end
