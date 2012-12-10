//
//  PhotoController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

-(id)initWithImage:(UIImage*)imageToDisplay{
    self = [super init];
    if (self) {
        
        // Show full screen image
        UIImageView* photoDisplayer = [[UIImageView alloc] init];
        if(IS_HEIGHT_GTE_568){
            [photoDisplayer setFrame:CGRectMake(0, 0, 400, 508)];
        }else{
            [photoDisplayer setFrame:CGRectMake(0, 0, 400, 420)];
        }
        
        photoDisplayer.opaque = NO;
        [photoDisplayer setImage:imageToDisplay];
        [self.view addSubview:photoDisplayer];
        [photoDisplayer release];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
