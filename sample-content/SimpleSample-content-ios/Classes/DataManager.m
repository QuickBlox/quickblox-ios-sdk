//
//  DataManager.m
//  SimpleSampleContent
//
//  Created by kirill on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"

static DataManager* instance = nil;

@implementation DataManager

@synthesize fileList = _fileList;
@synthesize images = _images;

+ (instancetype)instance
{
	static id instance_ = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

-(void)savePicture:(UIImage *)image{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    [_images addObject:image];
}

@end
