//
//  QBHTTPRequestSerialiser.h
//  Quickblox
//
//  Created by Andrey Kozlov on 24/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBRequestSerialisationProtocol.h"

@class QBRequest;

@interface QBHTTPRequestSerialiser : NSObject <QBRequestSerialisationProtocol>

+ (instancetype)serialiser;

/**
* The string encoding used to serialize parameters. `NSUTF8StringEncoding` by default.
*/
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**
* HTTP methods for which serialized requests will encode parameters as a query string. `GET`, `HEAD`, and `DELETE` by default.
*/
@property (nonatomic, strong) NSSet *HTTPMethodsEncodingParametersInURI;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                forRequest:(QBRequest *)request
                                     error:(NSError *__autoreleasing *)error;

- (void)printParametersFromRequest:(QBRequest *)request;

@end
