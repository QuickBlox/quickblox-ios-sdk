//
// Created by Andrey Kozlov on 13/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBLogLevel) {
    QBLogLevelNothing   =      0,  //  0 - Nothing in Log
    QBLogLevelErrors    = 1 << 0,  //  1 - Can see Errors
    QBLogLevelWarnings  = 1 << 1,  //  2 - Can see Warnings
    QBLogLevelInfo      = 1 << 2,  //  4 - Some Information Loggs
    QBLogLevelNetwork   = 1 << 3,  //  8 - Network Logs
    QBLogLevelDebug     = NSUIntegerMax
};

typedef void (^QBLoggerCustomLogBlock)(NSString *string, QBLogLevel level);

#define functionDescription [NSString stringWithFormat:@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__]

#define QBLog(format, ...) [QBLogger info:format, __VA_ARGS__]
#define QBLWarning(format, ...) [QBLogger warning:format, __VA_ARGS__]
#define QBLError(format, ...) [QBLogger error:format, __VA_ARGS__]
#define QBLErrorF(format, ...) [QBLogger errorInFunction: functionDescription withFormat:format, __VA_ARGS__]
#define QBLNetwork(format, ...) [QBLogger networkLog: format, __VA_ARGS__]

@interface QBLogger : NSObject

+ (void)setCurrentLevel:(QBLogLevel)level;
+ (void)setLogBlock:(QBLoggerCustomLogBlock)block;

+ (void)logWithLevel:(QBLogLevel)level format:(NSString *)format, ...;

+ (void)info:(NSString *)format, ...;
+ (void)warning:(NSString *)format, ...;
+ (void)error:(NSString *)format, ...;
+ (void)errorInFunction:(NSString *)function withFormat:(NSString *)format, ...;
+ (void)networkLog:(NSString *)format, ...;

@end