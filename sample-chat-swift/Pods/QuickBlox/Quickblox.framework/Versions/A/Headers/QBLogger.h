//
// Created by Andrey Kozlov on 13/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

typedef NS_ENUM(NSUInteger, QBLogLevel) {
    QBLogLevelNothing   =      0,  //  0 - Nothing in Log
    QBLogLevelErrors    = 1 << 0,  //  1 - Can see Errors
    QBLogLevelWarnings  = 1 << 1,  //  2 - Can see Warnings
    QBLogLevelInfo      = 1 << 2,  //  4 - Some Information Loggs
    QBLogLevelNetwork   = 1 << 3,  //  8 - Network Logs
    QBLogLevelDebug     = NSUIntegerMax
};

typedef void (^QBLoggerCustomLogBlock)(NSString * QB_NONNULL_S string, QBLogLevel level);

#define functionDescription [NSString stringWithFormat:@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__]

#define QBLog(format, ...) [QBLogger info:format, __VA_ARGS__]
#define QBLWarning(format, ...) [QBLogger warning:format, __VA_ARGS__]
#define QBLError(format, ...) [QBLogger error:format, __VA_ARGS__]
#define QBLErrorF(format, ...) [QBLogger errorInFunction: functionDescription withFormat:format, __VA_ARGS__]
#define QBLNetwork(format, ...) [QBLogger networkLog: format, __VA_ARGS__]

@interface QBLogger : NSObject

+ (void)setCurrentLevel:(QBLogLevel)level;
+ (void)setLogBlock:(QB_NONNULL QBLoggerCustomLogBlock)block;

+ (void)logWithLevel:(QBLogLevel)level format:(QB_NONNULL NSString *)format, ...;

+ (void)info:(QB_NONNULL NSString *)format, ...;
+ (void)warning:(QB_NONNULL NSString *)format, ...;
+ (void)error:(QB_NONNULL NSString *)format, ...;
+ (void)errorInFunction:(QB_NONNULL NSString *)function withFormat:(QB_NONNULL NSString *)format, ...;
+ (void)networkLog:(QB_NONNULL NSString *)format, ...;

@end