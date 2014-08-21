//
//  QBCOPermissionsAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/4/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

@interface QBCOPermissionsAnswer : XmlAnswer{
@private
    QBCOPermissions *_permissions;
}

@property (nonatomic, readonly) QBCOPermissions *permissions;

@end
