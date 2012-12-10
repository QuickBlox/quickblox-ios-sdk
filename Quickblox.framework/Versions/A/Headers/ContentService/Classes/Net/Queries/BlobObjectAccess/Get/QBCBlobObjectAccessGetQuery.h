//
//  QBCBlobObjectAccessGetQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/13/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBCBlobObjectAccessGetQuery : QBCBlobObjectAccessQuery{
@protected
    NSUInteger blobId;
}
@property (nonatomic,readonly) NSUInteger blobId;

- (id)initWithBlobId:(NSUInteger)blobid;

@end
