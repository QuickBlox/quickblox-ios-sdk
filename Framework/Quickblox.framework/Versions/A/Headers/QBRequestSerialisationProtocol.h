//
// Created by Andrey Kozlov on 03/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRequest;

@protocol QBRequestSerialisationProtocol <NSObject>

/**
* Providing sufix which will be added in request path as last part.
*/
- (NSString *)requestSufix;

/**
* Defaut Headers for request
*/
- (NSDictionary *)requestHeaders;

/**
* Method for generating request Body from provided set of parameters
*
* @param parameters NSDictionary which contains set of parameters that will be taken for generation of a Request body in appropriate way
* @result NSData Request data.
*/
- (NSData *)requestHTTPBodyWithParameters:(NSDictionary *)parameters;

/**
* Request Serialisation method
*
* @param request Instance of fully seted up QBRequest
* @param path Path to service call
* @param method HTTPRequest Method
*/
- (NSURLRequest *)requestBySerialisingRequest:(NSURLRequest *)request withParameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error;

// TODO: ??? Move to Object category for serialisation
- (NSDictionary *)generateParametersForObject:(id)object;

@end