//
//  QBCOCustomObjectCreateQuery.h
//  Quickblox
//
//  Created by IgorKh on 8/15/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "QBCOCustomObjectQuery.h"

@class QBCOCustomObject;

@interface QBCOCustomObjectCreateQuery : QBCOCustomObjectQuery{
    QBCOCustomObject *object;
}

@property (nonatomic, readonly) QBCOCustomObject *object;

-(id)initWithObject:(QBCOCustomObject *)_object;

@end
