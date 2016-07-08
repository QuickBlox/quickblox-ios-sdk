//
//  QMSLog.h
//  QMServices
//
//  Created by Vitaliy Gorbachov on 6/17/16.
//  Copyright (c) 2016 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <inttypes.h>

// NSLog is unavailable for QMServices project
// Use QMSLog instead.
FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_UNAVAILABLE;

#ifdef __cplusplus
extern "C" {
#endif
    
void QMSLogSetEnabled(BOOL enabled);
BOOL QMSLogEnabled();
void QMSLog(NSString *format, ...);
void QMSLogv(NSString *format, va_list args);
    
#ifdef __cplusplus
}
#endif
