//
//  QBAPIClient.h
//  Quickblox
//
//  Created by Igor Khomenko on 11/19/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//
#import "QBAFHTTPClient.h"

@interface QBAPIClient : QBAFHTTPClient

+ (instancetype)shared;

@end
