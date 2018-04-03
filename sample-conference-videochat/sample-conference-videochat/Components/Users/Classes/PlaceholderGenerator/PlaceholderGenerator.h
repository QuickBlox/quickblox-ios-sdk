//
//  PlaceholderGenerator.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 08/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlaceholderGenerator : NSObject

+ (UIImage *)placeholderWithSize:(CGSize)size title:(NSString *)title;

+ (UIImage *)groupPlaceholderWithUsers:(NSArray *)users size:(NSUInteger)size;

+ (UIColor *)colorForString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
