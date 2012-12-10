//
//  QBCOCustomObjectGetQuery.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBCOCustomObjectGetQuery : QBCOCustomObjectQuery{
    NSMutableDictionary *getRequest;
    NSString *className;
}

@property (nonatomic, readonly) NSMutableDictionary *getRequest;
@property (nonatomic, readonly) NSString *className;

-(id)initWithClassName:(NSString *)_className request:(NSMutableDictionary *)_getRequest;

@end
