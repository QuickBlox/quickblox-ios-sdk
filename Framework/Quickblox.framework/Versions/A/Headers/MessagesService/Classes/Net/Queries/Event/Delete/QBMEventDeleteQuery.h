//
//  QBMEventDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBMEventDeleteQuery : QBMEventQuery{
    NSUInteger eventID;
}
@property (nonatomic) NSUInteger eventID;

- (id)initWithEventID:(NSUInteger)geodataID;

@end
