//
//  DataManager.h
//  SimpleSampleContent
//
//  Created by kirill on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This class is a store of user's images
//

@interface SSCContentManager : NSObject

@property (nonatomic,strong) NSMutableArray* fileList;
@property (nonatomic,strong) NSMutableArray* images;

+ (instancetype)instance;

- (void)savePicture:(UIImage*)image;

@end
