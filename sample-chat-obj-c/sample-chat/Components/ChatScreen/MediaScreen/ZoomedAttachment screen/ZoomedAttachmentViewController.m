//
//  ZoomedAttachmentViewController.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ZoomedAttachmentViewController.h"
#import <Photos/Photos.h>
#import "UIViewController+Alert.h"

@interface ZoomedAttachmentViewController ()
@property (strong, nonatomic) UIBarButtonItem *infoItem;
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
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    __weak __typeof(self) weakSelf = self;
    UIAction *saveImageAction = [UIAction actionWithTitle:@"Save attachment" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        __typeof(weakSelf)strongSelf = weakSelf;
        UIImage *image = strongSelf.zoomImageView.image;
        if (!image) {
            return;
        }
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    UIImageWriteToSavedPhotosAlbum(image, strongSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                    break;
                    
                case PHAuthorizationStatusDenied:
                    NSLog(@"User denied");
                    break;
                    
                default:
                    NSLog(@"Restricted");
                    break;
            }
        }];
    }];
    UIMenu *menu = [UIMenu menuWithTitle:@"" children: @[saveImageAction]];
    self.infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreInfo"] menu:menu];
    self.navigationItem.rightBarButtonItem = self.infoItem;
    self.infoItem.tintColor = UIColor.whiteColor;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.shadowImage = UIImage.new;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    
    self.view.backgroundColor = [UIColor blackColor];
    self.zoomImageView.frame = self.view.frame;
    self.zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.zoomImageView];
    CGFloat topBarHeight = self.view.window.windowScene.statusBarManager.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    self.zoomImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.zoomImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.zoomImageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.zoomImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.zoomImageView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-topBarHeight].active = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackAction:)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapBackAction:(UITapGestureRecognizer*)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *errorMessage = error ? @"Save error" : @"Saved!";
    [self showAnimatedAlertWithTitle:nil message:errorMessage fromViewController:self];
}

@end
