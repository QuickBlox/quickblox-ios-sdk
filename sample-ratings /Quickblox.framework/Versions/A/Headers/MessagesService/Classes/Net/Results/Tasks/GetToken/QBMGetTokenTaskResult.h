//
//  QBMGetTokenTaskResult.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBMGetTokenTaskResult : TaskResult {
	NSString *token;
}
@property (nonatomic,retain) NSString *token;

@end
