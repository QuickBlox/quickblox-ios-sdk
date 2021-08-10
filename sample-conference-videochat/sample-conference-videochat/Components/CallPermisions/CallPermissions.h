//
//  QBAVCallPermissions.h
//  sample-conference-videochat
//
//  Created by Injoit on 29/06/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallPermissions : NSObject

+ (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType presentingViewController:(UIViewController *)presentingViewController
                                completion:(void (^)(BOOL granted))completion;
@end

NS_ASSUME_NONNULL_END
