//
//  QBConnection+QBLocation.h
//  Quickblox
//
//  Created by Andrey Moskvin on 4/11/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBConnection.h"

@interface QBConnection (QBLocation)

+ (QBConnection *)locationSessionConnection;
+ (QBConnection *)locationUserConnection;

@end
