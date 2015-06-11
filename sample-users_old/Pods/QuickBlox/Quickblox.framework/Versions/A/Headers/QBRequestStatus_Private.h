//
//  QBRequestStatus_Private.h
//  Quickblox
//
//  Created by Andrey Kozlov on 01/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBRequestStatus.h"

@interface QBRequestStatus ()

+ (QBRequestStatus *)requestStatusForType:(QBRequestType)type completion:(float)completion;

- (instancetype)initWithRequestType:(QBRequestType)type completion:(float)completion;

@end
