//
//  QBCOCustomObjectPagedAnswer.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@class QBCOCustomObjectAnswer;

@interface QBCOCustomObjectPagedAnswer : XmlAnswer{
@private
    QBCOCustomObjectAnswer *customObjectAnswer;
	NSMutableArray *_objects;
    NSUInteger _count;
    NSUInteger _skip;
    NSUInteger _limit;
    
    BOOL countAnswer;
    
    NSArray *_notFoundObjectsIDs;
}
@property (nonatomic, readonly) NSMutableArray *objects;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger skip;
@property (nonatomic, readonly) NSUInteger limit;
@property (nonatomic, readonly) NSArray *notFoundObjectsIDs;

@end
