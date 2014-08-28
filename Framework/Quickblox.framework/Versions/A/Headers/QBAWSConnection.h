//
//  QBAWSConnection.h
//  Quickblox
//
//  Created by Andrey Moskvin on 8/7/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBHTTPConnection.h"

@interface QBAWSConnection : QBHTTPConnection

@property (nonatomic, strong) NSString* uploadBaseUrl;

+ (instancetype)connection;

@end
