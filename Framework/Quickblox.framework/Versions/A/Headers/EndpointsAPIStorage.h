//
//  EndpointsAPIStorage.h
//  Quickblox
//
//  Created by Igor Khomenko on 5/21/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

@interface EndpointsAPIStorage : NSObject

+ (instancetype)instance;

@property (copy) NSString *apiEndpoint;
@property (copy) NSString *chatEndpoint;
@property (copy) NSString *turnServerEndpoint;
@property (copy) NSString *S3BucketName;
@property (copy) NSDate *lastCheckDate;

- (void)retrieveEndpoints;
- (void)populateFromDictionary:(NSDictionary *)accountSettings;

@end
