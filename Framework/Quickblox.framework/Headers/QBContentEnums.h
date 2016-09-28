//
//  Enums.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.

typedef NS_ENUM(NSUInteger, QBCBlobStatus) {
    
    QBCBlobStatusNew,
    QBCBlobStatusLocked,
    QBCBlobStatusCompleted
};

typedef NS_ENUM(NSUInteger, QBCBlobObjectAccessType) {
    
    QBCBlobObjectAccessTypeRead,
    QBCBlobObjectAccessTypeWrite
};
