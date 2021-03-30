//
//  QBCOFile.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBCOFile : NSObject <NSCoding, NSCopying>

/** 
 The name of the file .
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 The content type of the file.
 */
@property (nonatomic, copy, nullable) NSString *contentType;

/**
 The data of the file.
 */
@property (nonatomic, strong, nullable) NSData *data;

/**
 The Local url of the file.
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

/** 
 Create file object.
 
 @return New instance of `QBCOFile`
 */
+ (instancetype)file;

@end

NS_ASSUME_NONNULL_END
