//
//  PhotoController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCPhotoViewController.h"

@interface SSCPhotoViewController ()

@end

@implementation SSCPhotoViewController

- (id)initWithImage:(UIImage*)imageToDisplay
{
    self = [super init];
    if (self) {
        // Show full screen image
        UIImageView* photoDisplayer = [[UIImageView alloc] init];
        photoDisplayer.opaque = NO;
        photoDisplayer.contentMode = UIViewContentModeScaleAspectFit;
        [photoDisplayer setImage:imageToDisplay];
        [self.view addSubview:photoDisplayer];
    }
    return self;
}

@end
