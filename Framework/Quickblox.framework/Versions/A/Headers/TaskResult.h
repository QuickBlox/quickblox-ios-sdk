//
//  TaskResult.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBResult.h"


@interface TaskResult : QBResult{
	NSMutableArray *errorsList;
	QBResult *failedResult;
}
@property (nonatomic,retain) NSMutableArray *errorsList;
@property (nonatomic,retain) QBResult *failedResult;

+ (TaskResult *)failedWithResult:(QBResult *)result;

@end