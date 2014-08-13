//
//  QBMultipartRequestSerialiser.h
//  Quickblox
//
//  Created by Andrey Kozlov on 11/06/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBHTTPRequestSerialiser.h"

extern NSString* const fileKey;
extern NSString* const fileDataKey;
extern NSString* const fileContentTypeKey;
extern NSString* const fileNameKey;

@interface QBMultipartRequestSerialiser : QBHTTPRequestSerialiser

@end
