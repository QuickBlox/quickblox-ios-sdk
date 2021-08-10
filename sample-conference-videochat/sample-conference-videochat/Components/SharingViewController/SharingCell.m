//
//  SharingCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
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
