//
//  QBCOCustomObjectGetQuery.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
#import "QBCOCustomObjectQuery.h"

@interface QBCOCustomObjectGetQuery : QBCOCustomObjectQuery{
    NSMutableDictionary *getRequest;
    NSString *className;
    NSString *ID;
    NSArray *IDs;
}

@property (nonatomic, readonly) NSMutableDictionary *getRequest;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly) NSArray *IDs;

-(id)initWithClassName:(NSString *)_className request:(NSMutableDictionary *)_getRequest;
-(id)initWithClassName:(NSString *)_className ID:(NSString *)_ID;
-(id)initWithClassName:(NSString *)_className IDs:(NSArray *)_IDs;

@end
