//
//  CallKitInfo.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 11.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallKitInfo.h"

@interface CallKitInfo ()
//MARK: - Properties
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, assign) BOOL hasVideo;

@end

@implementation CallKitInfo
//MARK: - Life Cycle
- (id)initWithSessionId:(NSString *)sessionId hasVideo:(BOOL)hasVideo {
    self = [super init];
    if (self) {
        self.sessionId = sessionId;
        self.uuid = sessionId.length ? [[NSUUID alloc] initWithUUIDString: sessionId] : NSUUID.UUID;
        self.hasVideo = hasVideo;
    }
    return self;
}

@end
