//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordInternal.h"
#import "QMCDRecordStack.h"

@implementation QMCDRecord

+ (void) cleanUp
{
    [QMCDRecordStack setDefaultStack:nil];
}

+ (NSString *) defaultStoreName;
{
    NSString *defaultName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];

    if (defaultName == nil)
    {
        defaultName = @"CoreDataStore.sqlite";
    }

    if (![defaultName hasSuffix:@"sqlite"])
    {
        defaultName = [defaultName stringByAppendingPathExtension:@"sqlite"];
    }

    return defaultName;
}

@end
