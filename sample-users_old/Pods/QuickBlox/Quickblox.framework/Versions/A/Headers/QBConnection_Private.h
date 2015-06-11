//
//  QBConnection_Private.h
//  Quickblox
//
//  Created by Andrey Kozlov on 01/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBConnection.h"

@class QBRequest;

@interface QBConnection ()

+ (instancetype)globalConnection;

+ (instancetype)globalSessionConnection;

@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@property (nonatomic, readonly) NSString *serviceAuthKey;
@property (nonatomic, readonly) NSString *serviceAuthSecret;
@property (nonatomic, readonly) QBConnectionZoneType serviceZone;
@property (nonatomic, readonly) NSString *apiDomain;

// Auto constructed parameter based on apiDomain, ServiceZone and servicePath.
@property (nonatomic, readonly) NSString *serviceEndpoint;

// Parameters that could be overridden in class cluster methods
@property (nonatomic, copy) NSString *servicePath;
@property (nonatomic) BOOL requireSessionHeader;

- (instancetype)initWithServicePath:(NSString *)servicePath;


- (NSURLRequest *)generateURLRequestFromRequest:(QBRequest *)request
                                        forPath:(NSString *)path
                                    usingMethod:(NSString *)method;

- (NSOperation *)generateRequestOperation:(QBRequest *)request
                                  forPath:(NSString *)path
                              usingMethod:(NSString *)method;

- (void)enqueueOperation:(NSOperation *)operation;

/**
* Request Execution method.
*
* @param request QBRequest setted up for sending
* @param path NSString last part in request path.
* @param method NSString Request method. String parameter from set of standard methods for requests: POST, GET, DELETE
*/
- (void)executeRequest:(QBRequest *)request
               forPath:(NSString *)path
           usingMethod:(NSString *)method;

@end
