/*
 *  Consts.h
 *  ContentService
 *
 *  Copyright 2010 QuickBlox team. All rights reserved.
 *
 */


extern NSString* const kContentServiceException;
extern NSString* const kContentServiceErrorDomain;
extern NSString* const kContentS3ErrorDomain;

// S3 Error Keys
extern NSString* const kContentS3ErrorKeyCode;
extern NSString* const kContentS3ErrorKeyMessage;
extern NSString* const kContentS3ErrorKeyRequestId;
extern NSString* const kContentS3ErrorKeyHostId;

// Blob status
extern NSString *const kQBCBlobStatusNew;
extern NSString *const kQBCBlobStatusLocked;
extern NSString *const kQBCBlobStatusCompleted;

#define EBL(B,C) E(kContentServiceException, B,C)
#define EBL2(B) E2(kContentServiceException, B)

#define blobsElement @"blobs"
#define blobElement @"blob"
