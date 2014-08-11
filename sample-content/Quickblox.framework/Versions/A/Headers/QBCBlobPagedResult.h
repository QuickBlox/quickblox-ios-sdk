//
//  QBCBlobPagedResult.h
//  ContentService
//
//  Created by Igor Khomenko on 6/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBCBlobPagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for get files. Represent an array of blobs */

@interface QBCBlobPagedResult : PagedResult

/** Array of QBCBlob objects */
@property (nonatomic,readonly) NSArray *blobs;

@end
