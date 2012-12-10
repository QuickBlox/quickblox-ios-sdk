//
//  DataManager.h
//  SimpleSampleContent
//
//  Created by kirill on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This class is a store of user's images
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject{
    
}
@property (nonatomic,retain) NSMutableArray* fileList;
@property (nonatomic,retain) NSMutableArray* images;

+(DataManager*)instance;

-(void)savePicture:(UIImage*)image;

@end
