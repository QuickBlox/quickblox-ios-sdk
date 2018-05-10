//
//  UIImageView+QMLocationSnapshot.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 7/7/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface UIImageView (QMLocationSnapshot)

- (void)setSnapshotWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@end
