//
//  UIImageView+QMLocationSnapshot.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 7/7/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UIImageView+QMLocationSnapshot.h"
#import "QMChatLocationSnapshotter.h"

#import <objc/runtime.h>

@interface UIImageView (_QMLocationSnapshot)

@property (strong, nonatomic, setter=qm_setSnapshotKey:) NSString *qm_snapshotKey;

@end

@implementation UIImageView (_QMLocationSnapshot)

- (NSString *)qm_snapshotKey {
    
    return objc_getAssociatedObject(self, @selector(qm_snapshotKey));
}

- (void)qm_setSnapshotKey:(NSString *)qm_snapshotKey {
    
    objc_setAssociatedObject(self, @selector(qm_snapshotKey), qm_snapshotKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIImageView (QMLocationSnapshot)

- (void)setSnapshotWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    self.image = nil;
    [self qm_cancelPreviousSnapshotCreation];
    
    NSString *key = [NSString stringWithFormat:@"%lf/%lf",locationCoordinate.latitude, locationCoordinate.longitude];
    
    self.qm_snapshotKey = key;
    
    __weak __typeof(self)weakSelf = self;
    [QMChatLocationSnapshotter snapshotForLocationCoordinate:locationCoordinate
                                                    withSize:self.bounds.size
                                                         key:key
                                                  completion:^(UIImage *snapshot) {
                                                      
                                                      __typeof(weakSelf)strongSelf = weakSelf;
                                                      if ([strongSelf.qm_snapshotKey isEqualToString:key]) {
                                                          
                                                          strongSelf.image = snapshot;
                                                      }
                                                  }];
}

#pragma mark - Private

- (void)qm_cancelPreviousSnapshotCreation {
    
    if (self.qm_snapshotKey != nil) {
        
        [QMChatLocationSnapshotter cancelSnapshotCreationForKey:self.qm_snapshotKey];
        self.qm_snapshotKey = nil;
    }
}

@end
