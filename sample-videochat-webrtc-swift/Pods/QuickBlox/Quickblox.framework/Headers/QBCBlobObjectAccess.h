//
//  QBCBlobObjectAccess.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Quickblox/QBCEntity.h>
#import <Quickblox/QBContentEnums.h>

/**
 *  QBCBlobObjectAccess class interface.
 *  This class represents entity that uses for upload file to server.
 */
@interface QBCBlobObjectAccess : NSObject <NSCoding, NSCopying>

/**
 *  Blob ID.
 */
@property (nonatomic, assign) NSUInteger blobID;

/** 
 *  Link access type.
 */
@property (nonatomic, assign) QBCBlobObjectAccessType type;

/** 
 *  Reference expiration time.
 */
@property (nonatomic, strong, nullable) NSDate *expires;

/** 
 *  Url with params.
 *
 *  @discussion Use it for upload file.
 */
@property (nonatomic, copy, nullable) NSString *urlWithParams;

/**
 *  Params. 
 *
 *  @discussion Use them for upload file.
 */
@property (nonatomic, copy, nullable) NSDictionary *params;

/** 
 *  Url with params.
 *
 *  @discussion Use it for upload file.
 */
@property (nonatomic, strong, nullable) NSURL *url;

/** 
 *  Check link expiration date.
 *
 *  @return YES if link is expired, otherwise NO
 */
@property (nonatomic, readonly) BOOL expired;

@end
