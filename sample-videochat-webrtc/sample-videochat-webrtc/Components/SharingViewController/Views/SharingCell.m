//
//  SharingCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SharingCell.h"

@interface SharingCell()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@end

@implementation SharingCell
//MARK - Setup
- (void)setupImageName:(NSString *)imageName {
    self.imagePreview.image = [UIImage imageNamed:imageName];
}

@end
