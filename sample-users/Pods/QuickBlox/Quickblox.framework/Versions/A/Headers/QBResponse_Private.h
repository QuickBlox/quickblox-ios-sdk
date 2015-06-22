//
//  QBResponse_Private.h
//  Quickblox
//
//  Created by Andrey Kozlov on 01/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBResponse.h"

@class QBError;
@interface QBResponse ()

@property (nonatomic, readwrite) QBResponseStatusCode status;
@property (nonatomic, readwrite) NSDictionary *headers;
@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) QBError *error;
@property (nonatomic, readwrite) NSURL *requestUrl;

+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error;
+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error headers:(NSDictionary *)headers;
+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error headers:(NSDictionary *)headers status:(QBResponseStatusCode)status;
+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error
                         headers:(NSDictionary *)headers status:(QBResponseStatusCode)status
                      requestUrl:(NSURL *)requestUrl;

- (instancetype)initWithData:(NSData *)data error:(NSError *)error;

@end
