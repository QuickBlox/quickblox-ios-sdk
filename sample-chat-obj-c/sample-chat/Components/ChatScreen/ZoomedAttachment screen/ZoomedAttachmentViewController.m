//
//  ZoomedAttachmentViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ZoomedAttachmentViewController.h"

@interface ZoomedAttachmentViewController ()

@end

@implementation ZoomedAttachmentViewController

#pragma mark - Life Cycle
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.zoomImageView = [[UIImageView alloc] initWithImage:image];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.zoomImageView.frame = self.view.frame;
    self.zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.zoomImageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackAction:)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Internal Methods
- (void)didTapBackAction:(UITapGestureRecognizer*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
