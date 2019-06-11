//
//  ChatResources.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatResources : NSObject

+ (NSBundle *)resourceBundle;

+ (UIImage *)imageNamed:(NSString *)name;
+ (UINib *)nibWithNibName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
