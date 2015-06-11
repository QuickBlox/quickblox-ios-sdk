//
//  QBHTTPResponseSerialiser.h
//  Quickblox
//
//  Created by Andrey Kozlov on 24/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBResponseSerialisationProtocol.h"

@interface QBHTTPResponseSerialiser : NSObject <QBResponseSerialisationProtocol>

+ (instancetype)serialiser;

- (NSString *)uniqueID;

/**
* Validates the specified response and data.
*
* In its base implementation, this method checks for an acceptable status code and content type. Subclasses may wish to add other domain-specific checks.
*
* @param responseObject The data associated with the response.
* @param error The error that occurred while attempting to validate the response.
*
* @return `YES` if the response is valid, otherwise `NO`.
*/
- (BOOL)validateResponseObject:(id)responseObject
                         error:(NSError *__autoreleasing *)error;

@end
