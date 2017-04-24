//
//  QBCOFileUploadInfo.h
//  Quickblox
//
//  Created by QuickBlox team on 8/7/14.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBCOFileUploadInfo : NSObject<NSCoding, NSCopying>

/**
 *  Unique file ID.
 */
@property (nonatomic, copy, nullable) NSString *fileIdentifier;

/**
 *  Size of uploaded file, in bytes.
 */
@property (nonatomic, assign) NSUInteger size;

/**
 *  File name (min 1 chars. max 100 chars)
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 *  Portable Network Graphics; mime content type (max 50 chars).
 */
@property (nonatomic, copy, nullable) NSString *contentType;

@end
