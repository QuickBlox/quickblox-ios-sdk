//
//  QBCOCustomObjectsUpdateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//
#import "QBCOCustomObjectQuery.h"

@interface QBCOCustomObjectsUpdateQuery : QBCOCustomObjectQuery{
    NSArray *objects;
    NSString *className;
    NSArray *specialUpdateOperators;
}
@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSArray *specialUpdateOperators;

-(id)initWithObjects:(NSArray *)objects className:(NSString *)className specialUpdateOperators:(NSArray *)specialUpdateOperators;

@end
