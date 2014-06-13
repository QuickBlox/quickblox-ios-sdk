//
//  QBResponse_Private.h
//  Quickblox
//
//  Created by Andrey Kozlov on 01/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBResponse.h"

@interface QBResponse ()

@property (nonatomic, readwrite) QBResponseStatusCode status;
@property (nonatomic, readwrite) NSDictionary *headers;
@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) NSError *error;

+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error;
+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error headers:(NSDictionary *)headers;
+ (QBResponse *)responseWithData:(NSData *)data error:(NSError *)error headers:(NSDictionary *)headers status:(QBResponseStatusCode)status;

- (instancetype)initWithData:(NSData *)data error:(NSError *)error;

@end
