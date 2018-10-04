//
//  UIDevice+QBPerformance.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (QBPerformance)

/**
 *  Whether device is in low performance category and should be treated like that.
 *
 *  @device Use this check to determine whether your device is in low device category.
 *  This should be helpful to determine whether you need to hardcode low resolution and low
 *  audio codec in order to let device perform well without any problems.
 *
 *  @remark Low performance device list:
 iPod1,1, iPod2,1, iPod3,1, iPod4,1, iPod5,1,
 iPhone1,1, iPhone1,2, iPhone2,1, iPhone3,1, iPhone4,1,
 iPad1,1, iPad2,1, iPad2,2, iPad2,3, iPad2,4,
 iPad2,5, iPad2,6, iPad2,7
 */
@property (nonatomic, readonly, getter=qbrtc_isLowPerformance) BOOL qbrtc_lowPerformance;

/**
 *  Whether device is in medium performance category and should be treated like that.
 *
 *  @device Use this check to determine whether your device is in medium device category.
 *  This should be helpful to determine whether you need to hardcode medium resolution and 
 *  medium audio codec in order to let device perform well without any problems.
 *
 *  @remark Medium performance device list:
 iPad3,1, iPad3,2, iPad3,3, iPad3,4, iPad3,5, iPad3,6,
 iPhone5,1, iPhone5,2
 */
@property (nonatomic, readonly, getter=qbrtc_isMediumPerformance) BOOL qbrtc_mediumPerformance;

@end
