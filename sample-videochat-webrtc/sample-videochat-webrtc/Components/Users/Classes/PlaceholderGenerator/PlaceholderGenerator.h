//
//  PlaceholderGenerator.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlaceholderGenerator : NSObject

+ (UIImage *)placeholderWithSize:(CGSize)size title:(NSString *)title;

+ (UIImage *)groupPlaceholderWithUsers:(NSArray *)users size:(NSUInteger)size;

+ (UIColor *)colorForString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
