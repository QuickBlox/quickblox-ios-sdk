//
//  TaskResult.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaskResult : Result {
	NSMutableArray *errorsList;
	Result *failedResult;
}
@property (nonatomic,retain) NSMutableArray *errorsList;
@property (nonatomic,retain) Result *failedResult;

+ (TaskResult *)failedWithResult:(Result *)result;

@end