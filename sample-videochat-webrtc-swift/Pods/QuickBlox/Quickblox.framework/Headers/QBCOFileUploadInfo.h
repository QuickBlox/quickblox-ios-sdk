//
//  QBCOFileUploadInfo.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
