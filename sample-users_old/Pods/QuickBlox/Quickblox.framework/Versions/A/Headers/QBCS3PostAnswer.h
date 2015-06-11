//
//  QBCS3PostAnswer.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCS3Answer.h"


@interface QBCS3PostAnswer : QBCS3Answer {
	NSURL* location;
	NSString* bucket;
	NSString* key;
	NSString* eTag;
}
@property (nonatomic,retain) NSURL* location;
@property (nonatomic,retain) NSString* bucket;
@property (nonatomic,retain) NSString* key;
@property (nonatomic,retain) NSString* eTag;

@end
