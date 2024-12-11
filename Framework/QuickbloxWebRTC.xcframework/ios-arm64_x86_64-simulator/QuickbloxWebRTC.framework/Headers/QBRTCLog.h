//
//  QBRTCLog.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <QuickbloxWebRTC/QBRTCTypes.h>

#if defined(__cplusplus)
extern "C" void QBRTCLogEx(QBRTCLogLevel severity, NSString *logString);
extern "C" void QBRTCSetMinDebugLogLevel(QBRTCLogLevel severity);
extern "C" NSString *QBRTCFileName(const char* filePath);
#else
// Wrapper for C++ LOG(sev) macros.
// Logs the log string to the webrtc logstream for the given severity.
extern void QBRTCLogEx(QBRTCLogLevel severity, NSString *logString);
// Wrapper for rtc::LogMessage::LogToDebug.
// Sets the minimum severity to be logged to console.
extern void QBRTCSetMinDebugLogLevel(QBRTCLogLevel severity);
extern NSString *QBRTCFileName(const char* file_path);
#endif

#define QBRTCLogFormat(severity, format, ...)                               \
    QBRTCLogEx(severity, [NSString stringWithFormat:format, ##__VA_ARGS__]) \

#define QBRTCLogVerbose(format, ...)                                        \
        QBRTCLogFormat(QBRTCLogLevelVerbose, format, ##__VA_ARGS__)         \

#define QBRTCLogInfo(format, ...)                                           \
        QBRTCLogFormat(QBRTCLogLevelInfo, format, ##__VA_ARGS__)            \

#define QBRTCLogWarning(format, ...)                                        \
        QBRTCLogFormat(QBRTCLogLevelWarnings, format, ##__VA_ARGS__)        \

#define QBRTCLogError(format, ...)                                          \
        QBRTCLogFormat(QBRTCLogLevelErrors, format, ##__VA_ARGS__)          \

#define QBRTCLog(format, ...) QBRTCLogInfo(format, ##__VA_ARGS__)
