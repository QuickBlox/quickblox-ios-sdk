//
//  QBCOCustomObjectUpdateQuery.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBCOCustomObjectUpdateQuery : QBCOCustomObjectQuery{
    QBCOCustomObject *object;
    NSMutableDictionary *specialUpdateOperators;
}
@property (nonatomic, readonly) QBCOCustomObject *object;
@property (nonatomic, readonly) NSMutableDictionary *specialUpdateOperators;

-(id)initWithObject:(QBCOCustomObject *)_object specialUpdateOperators:(NSMutableDictionary *)specialUpdateOperators;

@end
