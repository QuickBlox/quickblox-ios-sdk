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
    NSString *ID;
}

@property (nonatomic, readonly) NSMutableDictionary *getRequest;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *ID;

-(id)initWithClassName:(NSString *)_className request:(NSMutableDictionary *)_getRequest;
-(id)initWithClassName:(NSString *)_className ID:(NSString *)_ID;

@end
