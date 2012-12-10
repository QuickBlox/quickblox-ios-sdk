//
//  QBCOCustomObject
//  Quickblox
//
//  Created by IgorKh on 8/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//


/** QBCOCustomObject class declaration. */
/** Overview */
/** This class represents QuickBlox custom object. */

@interface QBCOCustomObject : NSObject <NSCoding, NSCopying>{
@private
    NSString *className;
    NSMutableDictionary *fields;
    NSUInteger userID;
    NSString *ID;
    NSDate *createdAt;
    NSDate *updatedAt;
}

/** Object ID */
@property (nonatomic, retain) NSString *ID;

/** Date & time when record was created, filled automatically */
@property (nonatomic,retain) NSDate* createdAt;

/** Date & time when record was updated, filled automatically */
@property (nonatomic,retain) NSDate* updatedAt;

/** Class name */
@property (nonatomic,retain) NSString* className;

/** User's ID, which created current record */
@property (nonatomic) NSUInteger userID;

/** Custom object's fields */
@property (nonatomic,retain) NSMutableDictionary* fields;

/** Create new custom object
 @return New instance of QBCustomObject
 */
+ (QBCOCustomObject *)customObject;

@end
