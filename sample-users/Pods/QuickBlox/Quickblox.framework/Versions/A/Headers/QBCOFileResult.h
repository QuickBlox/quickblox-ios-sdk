//
//  QBCOFileResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/10/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

/** QBCOFileResult class declaration. */
/** Overview */
#import "Result.h"

/** This class is an instance, which will be returned to user after he made ​​the request for download a file. */
@interface QBCOFileResult : Result

/** File */
@property (nonatomic,readonly) NSData* data;

@end
