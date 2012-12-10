//
//  QBCFileDownloadTask.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/15/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBCFileDownloadTask : Task{
    NSUInteger blobID;
    QBCBlob *blob;
}
@property (nonatomic) NSUInteger blobID;
@property (nonatomic, retain)  QBCBlob *blob;

@end
