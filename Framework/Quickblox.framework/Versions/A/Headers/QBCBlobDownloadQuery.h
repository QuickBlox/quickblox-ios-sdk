//
//  QBCBlobDownloadQuery.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCBlobQuery.h"


@interface QBCBlobDownloadQuery : QBCBlobQuery {
@private
	NSString* UID;

}
@property (nonatomic,readonly) NSString* UID;

-(id)initWithBlobUID:(NSString*)blobUID;

@end
