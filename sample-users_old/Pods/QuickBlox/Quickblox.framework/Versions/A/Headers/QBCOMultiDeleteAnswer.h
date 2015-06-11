//
//  QBCOMultiDeleteAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@interface QBCOMultiDeleteAnswer : XmlAnswer{
@private
    NSArray *_deletedObjectsIDs;
    NSArray *_notFoundObjectsIDs;
    NSArray *_wrongPermissionsObjectsIDs;
}

@property (nonatomic, readonly) NSArray *deletedObjectsIDs;
@property (nonatomic, readonly) NSArray *notFoundObjectsIDs;
@property (nonatomic, readonly) NSArray *wrongPermissionsObjectsIDs;

@end
