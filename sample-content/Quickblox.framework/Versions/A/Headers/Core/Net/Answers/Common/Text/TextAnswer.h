//
//  TextAnswer.h
//  Core
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextAnswer : RestAnswer {
	NSString* text;
}
@property (nonatomic,retain) NSString* text;
@end
