//
//  QMCDRecordLogging.h
//  QMCDRecord
//
//  Created by Injoit on 10/4/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#ifndef QMCDRecord_QMCDRecordLogging_h
#define QMCDRecord_QMCDRecordLogging_h

#import "QMCDRecord+Options.h"

#define QMLOG_ASYNC_ENABLED YES

#define QMLOG_ASYNC_ERROR   ( NO && QMLOG_ASYNC_ENABLED)
#define QMLOG_ASYNC_WARN    (YES && QMLOG_ASYNC_ENABLED)
#define QMLOG_ASYNC_INFO    (YES && QMLOG_ASYNC_ENABLED)
#define QMLOG_ASYNC_VERBOSE (YES && QMLOG_ASYNC_ENABLED)

#ifdef QM_LOGGING_ENABLED

#ifndef QMLOG_MACRO

#define QMLOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
NSLog (frmt, ##__VA_ARGS__)

#define QMLOG_MAYBE(async, lvl, flg, ctx, fnct, frmt, ...) \
do { if ((lvl & flg) == flg) { QMLOG_MACRO(async, lvl, flg, ctx, nil, fnct, frmt, ##__VA_ARGS__); } } while(0)

#define QMLOG_OBJC_MAYBE(async, lvl, flg, ctx, frmt, ...) \
QMLOG_MAYBE(async, lvl, flg, ctx, sel_getName(_cmd), frmt, ##__VA_ARGS__)

#define QMLOG_C_MAYBE(async, lvl, flg, ctx, frmt, ...) \
QMLOG_MAYBE(async, lvl, flg, ctx, __FUNCTION__, frmt, ##__VA_ARGS__)

#endif

#define QMCDLogFatal(frmt, ...)   QMLOG_OBJC_MAYBE(QMLOG_ASYNC_ERROR,   [QMCDRecord loggingLevel], QMCDRecordLoggingMaskFatal,   0, frmt, ##__VA_ARGS__)
#define QMCDLogError(frmt, ...)   QMLOG_OBJC_MAYBE(QMLOG_ASYNC_ERROR,   [QMCDRecord loggingLevel], QMCDRecordLoggingMaskError,   0, frmt, ##__VA_ARGS__)
#define QMCDLogWarn(frmt, ...)    QMLOG_OBJC_MAYBE(QMLOG_ASYNC_WARN,    [QMCDRecord loggingLevel], QMCDRecordLoggingMaskWarn,    0, frmt, ##__VA_ARGS__)
#define QMCDLogInfo(frmt, ...)    QMLOG_OBJC_MAYBE(QMLOG_ASYNC_INFO,    [QMCDRecord loggingLevel], QMCDRecordLoggingMaskInfo,    0, frmt, ##__VA_ARGS__)
#define QMCDLogVerbose(frmt, ...) QMLOG_OBJC_MAYBE(QMLOG_ASYNC_VERBOSE, [QMCDRecord loggingLevel], QMCDRecordLoggingMaskVerbose, 0, frmt, ##__VA_ARGS__)

#define QMCDLogCFatal(frmt, ...)   QMLOG_C_MAYBE(QMLOG_ASYNC_ERROR,   [QMCDRecord loggingLevel], QMCDRecordLoggingMaskFatal,   0, frmt, ##__VA_ARGS__)
#define QMCDLogCError(frmt, ...)   QMLOG_C_MAYBE(QMLOG_ASYNC_ERROR,   [QMCDRecord loggingLevel], QMCDRecordLoggingMaskError,   0, frmt, ##__VA_ARGS__)
#define QMCDLogCWarn(frmt, ...)    QMLOG_C_MAYBE(QMLOG_ASYNC_WARN,    [QMCDRecord loggingLevel], QMCDRecordLoggingMaskWarn,    0, frmt, ##__VA_ARGS__)
#define QMCDLogCInfo(frmt, ...)    QMLOG_C_MAYBE(QMLOG_ASYNC_INFO,    [QMCDRecord loggingLevel], QMCDRecordLoggingMaskInfo,    0, frmt, ##__VA_ARGS__)
#define QMCDLogCVerbose(frmt, ...) QMLOG_C_MAYBE(QMLOG_ASYNC_VERBOSE, [QMCDRecord loggingLevel], QMCDRecordLoggingMaskVerbose, 0, frmt, ##__VA_ARGS__)

#else

#define QMCDLogFatal(frmt, ...) ((void)0)
#define QMCDLogError(frmt, ...) ((void)0)
#define QMCDLogWarn(frmt, ...) ((void)0)
#define QMCDLogInfo(frmt, ...) ((void)0)
#define QMCDLogVerbose(frmt, ...) ((void)0)

#define QMCDLogCFatal(frmt, ...) ((void)0)
#define QMCDLogCError(frmt, ...) ((void)0)
#define QMCDLogCWarn(frmt, ...) ((void)0)
#define QMCDLogCInfo(frmt, ...) ((void)0)
#define QMCDLogCVerbose(frmt, ...) ((void)0)

#endif

#endif
