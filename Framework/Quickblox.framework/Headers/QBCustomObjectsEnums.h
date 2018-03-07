//
//  Enums.h
//  Quickblox
//
//  Created by QuickBlox team on 7/5/13.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum QBCOPermissionsAccess {
	QBCOPermissionsAccessOpen,
	QBCOPermissionsAccessOwner,
    QBCOPermissionsAccessNotAllowed,
    QBCOPermissionsAccessOpenForUsersIDs,
    QBCOPermissionsAccessOpenForGroups,
} QBCOPermissionsAccess;
