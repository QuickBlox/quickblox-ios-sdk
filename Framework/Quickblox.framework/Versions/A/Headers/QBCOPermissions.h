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

/** QBCOPermissions class declaration. */
/** Overview */
/** This class represents QuickBlox custom object permissions. */

@interface QBCOPermissions : NSObject <NSCoding, NSCopying>{
@private
    NSString *recordID;
    enum QBCOPermissionsAccess readAccess;
    enum QBCOPermissionsAccess updateAccess;
    enum QBCOPermissionsAccess deleteAccess;
    
    NSMutableArray *usersIDsForReadAccess;
    NSMutableArray *usersGroupsForReadAccess;
    
    NSMutableArray *usersIDsForUpdateAccess;
    NSMutableArray *usersGroupsForUpdateAccess;
    
    NSMutableArray *usersIDsForDeleteAccess;
    NSMutableArray *usersGroupsForDeleteAccess;
}

/** Record ID */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *recordID;

/** Read access */
@property (nonatomic, assign) QBCOPermissionsAccess readAccess;

/** Update access */
@property (nonatomic, assign) QBCOPermissionsAccess updateAccess;

/** Delete access */
@property (nonatomic, assign) QBCOPermissionsAccess deleteAccess;

/** Users IDs  for read access */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableArray QB_GENERIC(NSString *) *usersIDsForReadAccess;

/** Users groups for read access */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableArray QB_GENERIC(NSString *) *usersGroupsForReadAccess;

/** Users IDs  for update access */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableArray QB_GENERIC(NSString *) *usersIDsForUpdateAccess;

/** Users groups for update access */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableArray QB_GENERIC(NSString *) *usersGroupsForUpdateAccess;

/** Users IDs  for delete access */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableArray QB_GENERIC(NSString *) *usersIDsForDeleteAccess;

/** Users groups for delete access */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableArray QB_GENERIC(NSString *) *usersGroupsForDeleteAccess;


/** Create permissions object
 @return New instance of QBCOPermissions
 */
+ (QB_NONNULL instancetype)permissions;


#pragma mark -
#pragma mark Converters

+ (enum QBCOPermissionsAccess)permissionsAccessFromString:(QB_NONNULL NSString *)permissionsAccess;
+ (QB_NULLABLE NSString *)permissionsAccessToString:(enum QBCOPermissionsAccess)permissionsAccess;

@end
