//
//  QBCBlobRetainQuery.h
//  ContentService
//
//  Created by Igor Khomenko on 7/12/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBCBlobRetainQuery : QBCBlobQuery{
@private
    NSUInteger blobId;
}
@property (nonatomic,readonly) NSUInteger blobId;

-(id)initWithBlobId:(NSUInteger)blobid;

@end
