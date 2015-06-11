//
//  QBCOCustomObjectsCreateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBCOCustomObjectQuery.h"

@interface QBCOCustomObjectsCreateQuery : QBCOCustomObjectQuery{
    NSArray *objects;
    NSString *className;
}

@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, readonly) NSString *className;

-(id)initWithObjects:(NSArray *)objects className:(NSString *)className;

@end
