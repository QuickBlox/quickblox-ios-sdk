//
//  QBCOPermissions.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
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
@property (nonatomic, retain) NSString *recordID;

/** Read access */
@property (nonatomic, assign) QBCOPermissionsAccess readAccess;

/** Update access */
@property (nonatomic, assign) QBCOPermissionsAccess updateAccess;

/** Delete access */
@property (nonatomic, assign) QBCOPermissionsAccess deleteAccess;

/** Users IDs  for read access */
@property (nonatomic, retain) NSMutableArray *usersIDsForReadAccess;

/** Users groups for read access */
@property (nonatomic, retain) NSMutableArray *usersGroupsForReadAccess;

/** Users IDs  for update access */
@property (nonatomic, retain) NSMutableArray *usersIDsForUpdateAccess;

/** Users groups for update access */
@property (nonatomic, retain) NSMutableArray *usersGroupsForUpdateAccess;

/** Users IDs  for delete access */
@property (nonatomic, retain) NSMutableArray *usersIDsForDeleteAccess;

/** Users groups for delete access */
@property (nonatomic, retain) NSMutableArray *usersGroupsForDeleteAccess;


/** Create permissions object
 @return New instance of QBCOPermissions
 */
+ (QBCOPermissions *)permissions;


#pragma mark -
#pragma mark Converters

+ (enum QBCOPermissionsAccess)permissionsAccessFromString:(NSString *)permissionsAccess;
+ (NSString *)permissionsAccessToString:(enum QBCOPermissionsAccess)permissionsAccess;

@end
