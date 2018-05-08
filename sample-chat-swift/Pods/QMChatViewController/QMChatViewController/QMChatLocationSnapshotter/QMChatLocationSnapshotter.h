//
//  QMChatLocationSnapshotter.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 7/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^QMChatLocationSnapshotBlock)(UIImage *snapshot);

@interface QMChatLocationSnapshotter : NSObject

+ (void)snapshotForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate
                             withSize:(CGSize)size
                                  key:(NSString *)key
                           completion:(QMChatLocationSnapshotBlock)completion;

+ (void)cancelSnapshotCreationForKey:(NSString *)key;

@end
