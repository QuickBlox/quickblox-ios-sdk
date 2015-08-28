//
//  ContentViewController.m
//  sample-content
//
//  Created by Igor Khomenko on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ContentViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ContentViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the image
    //
    NSString *privateUrl = [self.file privateUrl];
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
