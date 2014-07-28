//
//  DataManager.m
//  SimpleSampleContent
//
//  Created by kirill on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SSCContentManager.h"

static SSCContentManager* instance = nil;

@implementation SSCContentManager

@synthesize fileList = _fileList;
@synthesize images = _images;

+ (instancetype)instance
{
	static id instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [SSCContentManager new];
	});
	
	return instance;
}

- (void)savePicture:(UIImage *)image
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    [_images addObject:image];
}

@end
