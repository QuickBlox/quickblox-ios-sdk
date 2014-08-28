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

+ (instancetype)instance;

- (void)saveFileList:(NSArray *)fileList;
- (QBCBlob *)lastObjectFromFileList;
- (BOOL)fileListIsEmpty;
- (void)removeLastObjectFromFileList;

- (void)savePicture:(UIImage*)image;
- (BOOL)imageArrayIsEmpty;

@end
