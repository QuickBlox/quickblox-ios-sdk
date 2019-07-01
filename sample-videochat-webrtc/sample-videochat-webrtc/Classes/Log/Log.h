//
//  Log.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif
    
    void LogSetEnabled(BOOL enabled);
    BOOL LogEnabled(void);
    void Log(NSString *format, ...);
    
#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
