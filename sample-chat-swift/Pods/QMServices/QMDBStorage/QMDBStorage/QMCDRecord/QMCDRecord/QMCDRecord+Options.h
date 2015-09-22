//
//  QMCDRecord+Options.h
//  QMCD Record
//
//  Created by Injoit on 3/6/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"

/**
 Defines "levels" of logging that will be used as values in a bitmask that filters log messages.

 @since Available in v2.3 and later.
 */
typedef NS_ENUM (NSInteger, QMCDRecordLoggingMask)
{
    /** Disable all logging */
    QMCDRecordLoggingMaskOff = 0,

    /** Log fatal errors */
    QMCDRecordLoggingMaskFatal = 1 << 0,

    /** Log all errors */
    QMCDRecordLoggingMaskError = 1 << 1,

    /** Log warnings, and all errors */
    QMCDRecordLoggingMaskWarn = 1 << 2,

    /** Log informative messagess, warnings and all errors */
    QMCDRecordLoggingMaskInfo = 1 << 3,

    /** Log verbose diagnostic information, messages, warnings and all errors */
    QMCDRecordLoggingMaskVerbose = 1 << 4,
};

/**
 Defines a mask for logging that will be used by to filter log messages.

 @since Available in v2.3 and later.
 */
typedef NS_ENUM (NSInteger, QMCDRecordLoggingLevel)
{
    /** Don't log anything */
    QMCDRecordLoggingLevelOff = 0,

    /** Log all fatal messages */
    QMCDRecordLoggingLevelFatal = (QMCDRecordLoggingMaskFatal),

    /** Log all errors and fatal messages */
    QMCDRecordLoggingLevelError = (QMCDRecordLoggingMaskFatal | QMCDRecordLoggingMaskError),

    /** Log warnings, errors and fatal messages */
    QMCDRecordLoggingLevelWarn = (QMCDRecordLoggingMaskFatal | QMCDRecordLoggingMaskError | QMCDRecordLoggingMaskWarn),

    /** Log informative, warning and error messages */
    QMCDRecordLoggingLevelInfo = (QMCDRecordLoggingMaskFatal | QMCDRecordLoggingMaskError | QMCDRecordLoggingMaskWarn | QMCDRecordLoggingMaskInfo),

    /** Log verbose diagnostic, informative, warning and error messages */
    QMCDRecordLoggingLevelVerbose = (QMCDRecordLoggingMaskFatal | QMCDRecordLoggingMaskError | QMCDRecordLoggingMaskWarn | QMCDRecordLoggingMaskInfo | QMCDRecordLoggingMaskVerbose),
};

/**
 Provides options for configuring QMCDRecord.
 */
@interface QMCDRecord (Options)

/**
 @name Logging Level
 */

/**
 Returns the current logging level for QMCDRecord in the current application.

 @return Current QMCDRecordLoggingLevel
 
 @since Available in v2.3 and later.
 */
+ (QMCDRecordLoggingLevel) loggingLevel;

/**
 Sets the logging level for QMCDRecord in the current application.

 @param level Any value from QMCDRecordLoggingLevel

 @since Available in v2.3 and later.
 */
+ (void) setLoggingLevel:(QMCDRecordLoggingLevel)level;

@end
