//
//  FileParameter.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCoreEnums.h"

@interface FileParameter : NSObject {
	NSString* paramName;
	NSString* fileName;
	NSString* filePath;
	NSString* contentType;
	NSData* fileData;
	enum FileParameterType type;
}
@property (nonatomic,retain) NSString* paramName;
@property (nonatomic,retain) NSString* fileName;
@property (nonatomic,retain) NSString* filePath;
@property (nonatomic,retain) NSString* contentType;
@property (nonatomic,retain) NSData* fileData;
@property (nonatomic) enum FileParameterType type;

@end
