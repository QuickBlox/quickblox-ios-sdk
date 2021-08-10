//
//  ScreenCapture.h
//  QuickbloxWebRTC
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFormat.h"


@interface SharingScreenCapture: QBRTCVideoCapture

- (instancetype)initWithVideoFormat:(VideoFormat *)videoFormat;

@end
