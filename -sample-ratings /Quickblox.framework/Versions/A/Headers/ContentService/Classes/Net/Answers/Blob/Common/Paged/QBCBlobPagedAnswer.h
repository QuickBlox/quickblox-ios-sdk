//
//  QBCBlobPagedAnswer.h
//  ContentService
//
//  Created by Igor Khomenko on 6/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBCBlobPagedAnswer : PagedAnswer{
    QBCBlobAnswer *blobAnswer;
    NSMutableArray *blobs;
}

@property (nonatomic, retain) NSMutableArray *blobs;

@end
