//
//  QBRTCLog.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCTypes.h"

#if defined(__cplusplus)
extern "C" void QBRTCLogEx(QBRTCLogLevel severity, NSString* logString);
extern "C" void QBRTCSetMinDebugLogLevel(QBRTCLogLevel severity);
extern "C" NSString* QBRTCFileName(const char* filePath);
#else
// Wrapper for C++ LOG(sev) macros.
// Logs the log string to the webrtc logstream for the given severity.
extern void QBRTCLogEx(QBRTCLogLevel severity, NSString* logString);
// Wrapper for rtc::LogMessage::LogToDebug.
// Sets the minimum severity to be logged to console.
extern void QBRTCSetMinDebugLogLevel(QBRTCLogLevel severity);
extern NSString* QBRTCFileName(const char* file_path);
#endif

#define QBRTCLogString(format, ...)                                         \
    [NSString stringWithFormat:@"rtc::" format,                             \
        ##__VA_ARGS__]

#define QBRTCLogFormat(severity, format, ...)                               \
    do {                                                                    \
        NSString *logString = QBRTCLogString(format, ##__VA_ARGS__);        \
        QBRTCLogEx(severity, logString);                                    \
    } while (false)

#define QBRTCLogVerbose(format, ...)                                        \
        QBRTCLogFormat(QBRTCLogLevelVerbose, format, ##__VA_ARGS__)         \

#define QBRTCLogInfo(format, ...)                                           \
        QBRTCLogFormat(QBRTCLogLevelInfo, format, ##__VA_ARGS__)            \

#define QBRTCLogWarning(format, ...)                                        \
        QBRTCLogFormat(QBRTCLogLevelWarnings, format, ##__VA_ARGS__)        \

#define QBRTCLogError(format, ...)                                          \
        QBRTCLogFormat(QBRTCLogLevelErrors, format, ##__VA_ARGS__)          \

#if !defined(DEBUG)
    #define QBRTCLogDebug(format, ...) QBRTCLogInfo(format, ##__VA_ARGS__)
#else
    #define QBRTCLogDebug(format, ...)                                      \
        do {                                                                \
        } while (false)
#endif

#define QBRTCLog(format, ...) QBRTCLogInfo(format, ##__VA_ARGS__)
