//
//  SharingCell.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 27/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SharingCell.h"

@interface SharingCell()


@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;

@end

@implementation SharingCell

- (void)setImageName:(NSString *)imageName {
    
    if (![_imageName isEqualToString:imageName]) {
        
        _imageName = imageName;
        
        self.imagePreview.image = [UIImage imageNamed:_imageName];
    }
}

@end
