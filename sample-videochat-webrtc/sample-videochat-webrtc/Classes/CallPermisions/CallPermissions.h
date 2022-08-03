//
//
//CallPermissions.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^СheckPermissionsCompletion)(BOOL granted);

@interface CallPermissions : NSObject

+ (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType presentingViewController:(UIViewController *)presentingViewController
                                completion:(СheckPermissionsCompletion)completion;
@end

NS_ASSUME_NONNULL_END
