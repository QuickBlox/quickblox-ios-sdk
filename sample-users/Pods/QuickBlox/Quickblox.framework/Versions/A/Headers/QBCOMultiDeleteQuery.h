//
//  QBCOMultiDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBCOCustomObjectQuery.h"

@interface QBCOMultiDeleteQuery : QBCOCustomObjectQuery{
    NSString *className;
    NSArray *objectsIDs;
}

@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSArray *objectsIDs;

-(id)initWithClassName:(NSString *)className objectsIDs:(NSArray *)objectsIDs;

@end
