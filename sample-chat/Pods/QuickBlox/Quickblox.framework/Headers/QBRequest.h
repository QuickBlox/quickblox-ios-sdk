//
// Created by QuickBlox team on 01/12/2013.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBResponse;
@class QBRequest;
@class QBRequestStatus;
@class QBError;

NS_ASSUME_NONNULL_BEGIN

/** Blocks typedef */
typedef void(^QBErrorBlock)(QBError *error);
typedef void(^qb_response_status_block_t)(QBRequest *request, QBRequestStatus *status);
typedef void(^qb_response_block_t)(QBResponse *response);

/**
 *  QBRequest class interface.
 *  This class represents all requests to Quickblox API.
 */
@interface QBRequest : NSObject

/// The NSURLSessionTask class is the base class for tasks in a URL session.
@property (nonatomic, readonly) NSURLSessionTask *task;

/// Determines if NSURLSessionTask was canceled.
@property (nonatomic, getter=isCancelled, readonly) BOOL canceled;

/** Unavailable Constructors */
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Cancels NSURLSessionTask associated with request.
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
