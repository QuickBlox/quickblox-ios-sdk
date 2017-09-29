//
//  QMSLog.m
//  QMServices
//
//  Created by Vitaliy Gorbachov on 6/17/16.
//  Copyright (c) 2016 Quickblox Team. All rights reserved.
//

#import "QMSLog.h"

static BOOL logEnabled = YES;

void QMSLogSetEnabled(BOOL enabled)
{
    logEnabled = enabled;
}

BOOL QMSLogEnabled()
{
    return logEnabled;
}

void QMSLog(NSString *format, ...)
{
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
