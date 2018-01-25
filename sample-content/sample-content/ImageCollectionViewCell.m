//
//  ImageCollectionViewCell.m
//  sample-content
//
//  Created by Andrey Moskvin on 9/4/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView sd_cancelCurrentAnimationImagesLoad];
}

@end
