//
//  QBRTCScreenCaptuerer.m
//  QuickbloxWebRTC
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SharingScreenCapture.h"

@interface SharingScreenCapture()

@property (strong, nonatomic) VideoFormat *videoFormat;

@end

@implementation SharingScreenCapture

- (instancetype)initWithVideoFormat:(VideoFormat *)videoFormat {
    
    self = [super init];
    if (self) {
        
        _videoFormat = videoFormat;
    }
    
    return self;
}


#pragma mark - <QBRTCVideoCapture>

- (void)didSetToVideoTrack:(QBRTCLocalVideoTrack *)videoTrack {
    [super didSetToVideoTrack:videoTrack];
    
    [self adaptOutputFormatToWidth:self.videoFormat.width height:self.videoFormat.height fps:self.videoFormat.fps];
}

@end
