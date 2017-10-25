//
// Created by QuickBlox team on 01/12/2013.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QBResponseStatusCode) {
    QBResponseStatusCodeCancelled           = NSURLErrorCancelled,
    QBResponseStatusCodeUnknown             = -1,
    QBResponseStatusCodeAccepted            = 202,
    QBResponseStatusCodeCreated             = 201,
    QBResponseStatusCodeForbidden           = 403,
    QBResponseStatusCodeNotFound            = 404,
    QBResponseStatusCodeOK                  = 200,
    QBResponseStatusCodeBadRequest          = 400,
    QBResponseStatusCodeServerError         = 500,
    QBResponseStatusCodeUnAuthorized        = 401,
    QBResponseStatusCodeValidationFailed    = 422
};

@class QBError;

@interface QBResponse : NSObject

@property (nonatomic, getter = isSuccess, readonly) BOOL success;

@property (nonatomic, readonly) QBResponseStatusCode status;
@property (nonatomic, readonly, nullable) QBError *error;

@end
