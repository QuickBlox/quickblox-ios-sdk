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

+(DataManager*)instance{
    if (!instance) {
        instance = [[DataManager alloc] init];
    }
    return instance;
}

-(void)savePicture:(UIImage *)image{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    [_images addObject:image];
}

@end
