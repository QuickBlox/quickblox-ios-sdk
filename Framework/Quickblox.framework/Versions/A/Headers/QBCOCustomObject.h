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

#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@class QBCOPermissions;

@interface QBCOCustomObject : NSObject <NSCoding, NSCopying>{
@private
    NSString *className;
    NSMutableDictionary *fields;
    NSUInteger userID;
    NSString *ID;
    NSString *parentID;
    NSDate *createdAt;
    NSDate *updatedAt;
    QBCOPermissions *permissions;
}

/** Object ID */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *ID;

/** Relations: parent object's ID */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *parentID;

/** Date & time when record was created, filled automatically */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSDate* createdAt;

/** Date & time when record was updated, filled automatically */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSDate* updatedAt;

/** Class name */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString* className;

/** User's ID, which created current record */
@property (nonatomic) NSUInteger userID;

/** Custom object's fields */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSMutableDictionary QB_GENERIC(NSString *, id) *fields;

/** Object permissions */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) QBCOPermissions *permissions;

/** Create new custom object
 @return New instance of QBCustomObject
 */
+ (QB_NONNULL instancetype)customObject;

@end
