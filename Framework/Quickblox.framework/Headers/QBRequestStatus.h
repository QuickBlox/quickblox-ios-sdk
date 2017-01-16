//
// Created by QuickBlox team on 01/12/2013.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBRequestType) {
    QBRequestTypeUnknown,
    QBRequestTypeDownload,
    QBRequestTypeUpload
};

@interface QBRequestStatus : NSObject

@property (nonatomic) QBRequestType requestType;
@property (nonatomic) float percentOfCompletion;

@end
