//
//  QBAVCallPermissions.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 29/06/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBAVCallPermissions : NSObject

+ (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType
                                completion:(PermissionBlock)completion;

@end

NS_ASSUME_NONNULL_END