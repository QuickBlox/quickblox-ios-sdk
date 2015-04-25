//
// Created by Andrey Kozlov on 05/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QBResponseSerialisationProtocol

/**
* Returns Unique ID
*/
+ (NSString *)uniqueID;

/**
* Return parsed object from JSON Dictionary.
*
* @param responseData responseData object, JSON Dictionary.
* @param error NSError
*/
- (id)objectFromParsedResponseData:(id)responseData error:(NSError *__autoreleasing *)error;

/**
* Main parsing method for response data.
*
* @param data NSDate that was taken from response
* @param error NSError which will be generated if there is any problems with response data format.
*
* @result id some object as a result of parsing in that method
*/
- (id)parseObjectFromResponseData:(NSData *)data error:(NSError *__autoreleasing *)error;

@end