//
//  Enums.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.

typedef enum QBCBlobStatus{
	QBCBlobStatusNew,
	QBCBlobStatusLocked,
	QBCBlobStatusCompleted
} QBCBlobStatus;

typedef enum QBCBlobObjectAccessType{
	QBCBlobObjectAccessTypeRead,
	QBCBlobObjectAccessTypeWrite
} QBCBlobObjectAccessType;