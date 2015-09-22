//
//  Created by Tony Arnold on 8/04/2014.
//  Copyright (c) 2014 QMCD Panda Software LLC. All rights reserved.
//

#import "QMCDRecord.h"

/**
 Defines current and historical version numbers of QMCDRecord.

 @since Available in v2.3 and later.
 */
typedef NS_ENUM(NSUInteger, QMCDRecordVersionNumber)
{
    /** Version 2.2.0 */
    QMCDRecordVersionNumber2_2 = 220,

    /** Version 2.3.0 */
    QMCDRecordVersionNumber2_3 = 230,

    /** Version 3.0.0 */
    QMCDRecordVersionNumber3_0 = 300,
};

/**
 Provides an way for developers to retrieve the version of QMCDRecord they are currently using within their apps.

 @since Available in v2.3 and later.
 */
@interface QMCDRecord (VersionInformation)

///---------------------------
/// @name Version Information
///---------------------------

/**
 Returns the current version of QMCDRecord. See the QMCDRecordVersionNumber enumeration for valid current and historical values.

 @return The current version as a double.

 @since Available in v2.3 and later
 */
+ (QMCDRecordVersionNumber)version;

@end
