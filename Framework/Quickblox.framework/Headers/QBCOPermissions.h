//
//  QBCOPermissions.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBCustomObjectsEnums.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBCOPermissions class interface.
 *  This class represents QuickBlox custom object permissions. 
 */
@interface QBCOPermissions : NSObject <NSCoding, NSCopying>

/** 
 *  Record ID.
 */
@property (nonatomic, copy, nullable) NSString *recordID;

/** 
 *  Read access.
 */
@property (nonatomic, assign) QBCOPermissionsAccess readAccess;

/** 
 *  Update access.
 */
@property (nonatomic, assign) QBCOPermissionsAccess updateAccess;

/** 
 *  Delete access.
 */
@property (nonatomic, assign) QBCOPermissionsAccess deleteAccess;

/** 
 *  Users IDs  for read access.
 */
@property (nonatomic, strong, nullable) NSMutableArray QB_GENERIC(NSString *) *usersIDsForReadAccess;

/** 
 *  Users groups for read access.
 */
@property (nonatomic, strong, nullable) NSMutableArray QB_GENERIC(NSString *) *usersGroupsForReadAccess;

/** 
 *  Users IDs  for update access.
 */
@property (nonatomic, strong, nullable) NSMutableArray QB_GENERIC(NSString *) *usersIDsForUpdateAccess;

/** 
 *  Users groups for update access.
 */
@property (nonatomic, strong, nullable) NSMutableArray QB_GENERIC(NSString *) *usersGroupsForUpdateAccess;

/** 
 *  Users IDs for delete access.
 */
@property (nonatomic, strong, nullable) NSMutableArray QB_GENERIC(NSString *) *usersIDsForDeleteAccess;

/**
 *  Users groups for delete access.
 */
@property (nonatomic, strong, nullable) NSMutableArray QB_GENERIC(NSString *) *usersGroupsForDeleteAccess;


/** 
 *  Create permissions object
 *
 *  @return New instance of QBCOPermissions
 */
+ (instancetype)permissions;

#pragma mark -
#pragma mark Converters

+ (enum QBCOPermissionsAccess)permissionsAccessFromString:(NSString *)permissionsAccess;
+ (nullable NSString *)permissionsAccessToString:(enum QBCOPermissionsAccess)permissionsAccess;

@end

NS_ASSUME_NONNULL_END
