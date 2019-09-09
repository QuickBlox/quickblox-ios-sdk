//
//  Log.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import "Log.h"

static BOOL logEnabled = YES;

void LogSetEnabled(BOOL enabled) {
    logEnabled = enabled;
}

BOOL LogEnabled() {
    return logEnabled;
}

void Log(NSString *format, ...) {
    if (logEnabled)
    {
        va_list L;
        va_start(L, format);
        @autoreleasepool {
            NSLogv(format, L);
        }
        va_end(L);
    }
}
