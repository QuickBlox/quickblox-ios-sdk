//
//  QBCFileResult.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBCFileResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for download a file. */

@interface QBCFileResult : Result {
    
}
/** File */
@property (nonatomic,readonly) NSData* data;

@end
