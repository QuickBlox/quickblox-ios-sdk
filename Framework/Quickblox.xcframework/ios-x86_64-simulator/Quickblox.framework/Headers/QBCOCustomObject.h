//
//  QBCOCustomObject.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBCOPermissions;

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBCOCustomObject class interface.
 *  This class represents QuickBlox custom object model.
 *
 *  @see http://quickblox.com/developers/Custom_Objects#Module_description
 */
@interface QBCOCustomObject : NSObject <NSCoding, NSCopying>

/** 
 *  Object ID.
 */
@property (nonatomic, copy, nullable) NSString *ID;

/** 
 *  Relations: parent object's ID.
 */
@property (nonatomic, copy, nullable) NSString *parentID;

/** 
 *  Date & time when record was created, filled automatically.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/** 
 *  Date & time when record was updated, filled automatically.
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

/** 
 *  Class name.
 */
@property (nonatomic, copy, nullable) NSString *className;

/** 
 *  User's ID, which created current record.
 */
@property (nonatomic, assign) NSUInteger userID;

/** 
 *  Custom object's fields.
 */
@property (nonatomic, strong, null_resettable) NSMutableDictionary <NSString *, id> *fields;

/** 
 *  Object permissions.
 */
@property (nonatomic, strong, nullable) QBCOPermissions *permissions;

/** 
 *  Create new custom object.
 *
 *  @return New instance of QBCustomObject.
 */
+ (instancetype)customObject;

//MARK: Keyed subscription

- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
