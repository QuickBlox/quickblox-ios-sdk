//
//  PhotoAsset.h
//  samplechat
//
//  Created by Injoit on 3/10/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAsset : NSObject
@property (strong, nonatomic) PHAsset *phAsset;
@property (strong, nonatomic) UIImage *image;
@end

NS_ASSUME_NONNULL_END
