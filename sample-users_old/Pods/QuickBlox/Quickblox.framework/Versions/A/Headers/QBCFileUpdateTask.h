//
//  QBCFileUpdateTask.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

@class QBCBlob;

@interface QBCFileUpdateTask : Task{
    NSData *data;
	QBCBlob *blob;
}

@property (nonatomic,retain) NSData *data;
@property (nonatomic,retain) QBCBlob *blob;

@end
