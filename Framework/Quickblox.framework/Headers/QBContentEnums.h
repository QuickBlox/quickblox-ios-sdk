//
//  QBContentEnums.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBCBlobStatus) {
    
    QBCBlobStatusNew,
    QBCBlobStatusLocked,
    QBCBlobStatusCompleted
};

typedef NS_ENUM(NSUInteger, QBCBlobObjectAccessType) {
    
    QBCBlobObjectAccessTypeRead,
    QBCBlobObjectAccessTypeWrite
};
