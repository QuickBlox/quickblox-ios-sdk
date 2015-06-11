//
//  QBCOCustomObjectDeleteQuery.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "QBCOCustomObjectQuery.h"

@class QBCOCustomObject;

@interface QBCOCustomObjectDeleteQuery : QBCOCustomObjectQuery{
    QBCOCustomObject *object;
}

@property (nonatomic, readonly) QBCOCustomObject *object;

-(id)initWithObject:(QBCOCustomObject *)_object;

@end
