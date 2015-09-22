//
//  QMCDRecord+Options.m
//  QMCD Record
//
//  Created by Injoit on 3/6/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord+Options.h"

static QMCDRecordLoggingLevel magicalRecordLoggingLevel = QMCDRecordLoggingLevelVerbose;

@implementation QMCDRecord (Options)

+ (QMCDRecordLoggingLevel) loggingLevel;
{
    return magicalRecordLoggingLevel;
}

+ (void) setLoggingLevel:(QMCDRecordLoggingLevel)level;
{
    magicalRecordLoggingLevel = level;
}

@end
