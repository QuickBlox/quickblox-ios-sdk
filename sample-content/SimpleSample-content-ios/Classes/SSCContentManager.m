//
//  DataManager.m
//  SimpleSampleContent
//
//  Created by kirill on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SSCContentManager.h"

@interface SSCContentManager ()

@property (nonatomic, strong) NSMutableArray* fileList;
@property (nonatomic, strong) NSMutableArray* images;

@end

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

- (void)saveFileList:(NSArray *)fileList
{
    self.fileList = [NSMutableArray arrayWithArray:fileList];
}

- (QBCBlob *)lastObjectFromFileList
{
    return [self.fileList lastObject];
}

- (BOOL)fileListIsEmpty
{
    return self.fileList.count == 0;
}

- (void)removeLastObjectFromFileList
{
    [self.fileList removeLastObject];
}

- (BOOL)imageArrayIsEmpty
{
    return (self.images.count == 0);
}

@end
