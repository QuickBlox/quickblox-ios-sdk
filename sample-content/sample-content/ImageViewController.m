//
//  ContentViewController.m
//  sample-content
//
//  Created by Quickblox Team on 6/9/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "ImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ImageViewController ()

@property (weak, nonnull) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *privateUrl = [self.imageBlob privateUrl];
    if (privateUrl) {
        __weak typeof(self)weakSelf = self;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:privateUrl]
                          placeholderImage:nil options:0
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      NSString* progressText = [NSString stringWithFormat:@"%ld%%", (long)((float)(receivedSize * 100) / (float)expectedSize)];
                                      weakSelf.progressLabel.text = progressText;
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     weakSelf.progressLabel.hidden = YES;
                                 }];
    } else {
        NSLog(@"Private URL is NULL");
    }
}

@end
