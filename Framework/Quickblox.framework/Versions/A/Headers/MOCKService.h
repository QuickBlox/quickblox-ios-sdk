//
// Created by Andrey Kozlov on 03/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MOCKResponse;

typedef BOOL(^MOCKTestBlock)(NSURLRequest *request);
typedef MOCKResponse *(^MOCKResponseBlock)(NSURLRequest *request);

typedef id BMRequestHandlerID;

@interface MOCKService : NSObject

+ (void)setMOCKModeEnabled:(BOOL)enabled;

+ (BOOL)isMockMode;

/** Dedicated method to add a HTTP request handler
 @param testBlock Block that should return YES if the request passed as parameter should be stubbed with the handler block, NO if it should hit the real world (or be managed by another request handler).
 @param responseHandler Block that will return the OHHTTPStubsResponse to use for stubbing, corresponding to the given request
 @return an opaque object that uniquely identifies the handler and can be later used to remove it with removeRequestHandler:
 */
+ (BMRequestHandlerID)registerRequestHandlerWithCriteria:(MOCKTestBlock)testBlock response:(MOCKResponseBlock)responseBlock;

/** Remove a request handler from the list of stubs
@param handlerID the opaque object that has been returned when adding the handler using `stubRequestsPassingTest:withStubResponse:`
or using `addRequestHandler:`
@return YES if the request handler has been successfully removed, NO if the parameter was not a valid handler identifier
*/
+ (BOOL)removeRequestHandler:(BMRequestHandlerID)handlerID;

/** Remove the last added request handler from the stubs list */
+ (void)removeLastRequestHandler;

/** Remove all the requests handlers from the stubs list. */
+ (void)removeAllRequestHandlers;

/** Generates Response Class by given NSURLRequest
 @param request
 @param onlyCheck flag to say that we need only check if we need generate response for such request.
 @return BMRPCResponse class
 */
+ (MOCKResponse *)responseForRequest:(NSURLRequest *)request onlyCheck:(BOOL)onlyCheck;

@end