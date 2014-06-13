//
// Created by Andrey Kozlov on 03/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOCKResponse : NSObject

@property(nonatomic, copy) NSDictionary* httpHeaders;
@property(nonatomic) int statusCode;
@property(nonatomic, strong) NSData* responseData;
@property(nonatomic, strong) NSError* error;

/** @name Commodity constructors */

+ (instancetype)response;

/** Builds a response given raw data
 @param data The raw data to return in the response
 @param statusCode the HTTP Status Code to use in the response
 @param httpHeaders The HTTP Headers to return in the response
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 */
+ (instancetype)responseWithData:(NSData *)data
                      statusCode:(int)statusCode
                         headers:(NSDictionary *)httpHeaders;

/** Builds a response given a file in the application bundle, the status code and headers.
 @param fileName The file name and extension that contains the response body to return. The file must be in the application bundle
 @param statusCode the HTTP Status Code to use in the response
 @param httpHeaders The HTTP Headers to return in the response
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 */
+ (instancetype)responseWithFile:(NSString *)fileName
                      statusCode:(int)statusCode
                         headers:(NSDictionary *)httpHeaders;

/** Builds a response given a file in the application bundle and a content type.
 @param fileName The file name and extension that contains the response body to return. The file must be in the application bundle
 @param contentType the value to use for the "Content-Type" HTTP header
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 @note HTTP Status Code 200 will be used in the response
 */
+ (instancetype)responseWithFile:(NSString *)fileName
                     contentType:(NSString *)contentType;

/** Builds a response given a message data as returned by `curl -is [url]`, that is containing both the headers and the body.
 This method will split the headers and the body and build a OHHTTPStubsReponse accordingly
 @param responseData the NSData containing the whole HTTP response, including the headers and the body
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 */
+ (instancetype)responseWithHTTPMessageData:(NSData *)responseData;

/** Builds a response given the name of a "*.response" file containing both the headers and the body.
 The response file is expected to be in the specified bundle (or the application bundle if nil).
 This method will split the headers and the body and build a OHHTTPStubsReponse accordingly
 @param responseName the name of the "*.response" file (without extension) containing the whole HTTP response (including the headers and the body)
 @param bundle the bundle in which the "*.response" file is located. If `nil`, the `[NSBundle bundleForClass:self.class]` will be used.
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 */
+ (instancetype)responseNamed:(NSString *)responseName
                   fromBundle:(NSBundle *)bundle;

/** Builds a response that corresponds to the given error
 @param error The error to use in the stubbed response.
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 @note For example you could use an error like `[NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil]`
 */
+ (instancetype)responseWithError:(NSError *)error;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods

/** Designed initializer. Initialize a response with the given data, statusCode, responseTime and headers.
 @param data The raw data to return in the response
 @param statusCode the HTTP Status Code to use in the response
 @param httpHeaders The HTTP Headers to return in the response
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 */
- (instancetype)initWithData:(NSData *)data
                  statusCode:(int)statusCode
                     headers:(NSDictionary *)httpHeaders;

/** Designed initializer. Initialize a response with the given error.
 @param error The error to use in the stubbed response.
 @return an OHHTTPStubsResponse describing the corresponding response to return by the stub
 @note For example you could use an error like `[NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil]`
 */
- (instancetype)initWithError:(NSError *)error;

@end