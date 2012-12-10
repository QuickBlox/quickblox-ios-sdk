//
//  QBCOCustomObjectUpdateQuery.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBCOCustomObjectUpdateQuery : QBCOCustomObjectQuery{
    QBCOCustomObject *object;
}

@property (nonatomic, readonly) QBCOCustomObject *object;

-(id)initWithObject:(QBCOCustomObject *)_object;

@end
