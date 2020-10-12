//
//  ParentVideoVC.m
//  samplechat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ParentVideoVC.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import "UIColor+Chat.h"
#import "ActionsMenuViewController.h"
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

@interface ParentVideoVC () <UIPopoverPresentationControllerDelegate>
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVPlayerViewController *vc;
@end

@implementation ParentVideoVC

#pragma mark - Life Cycle
- (instancetype)initWithVideoUrl:(NSURL *)videoUrl {
    self = [super init];
    if (self) {
        self.videoURL = videoUrl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreInfo"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(didTapInfo:)];
    self.navigationItem.rightBarButtonItem = infoItem;
    infoItem.tintColor = UIColor.whiteColor;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.shadowImage = UIImage.new;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    
    if (self.videoURL) {
        AVPlayer *player = [AVPlayer playerWithURL:self.videoURL];
        self.vc = AVPlayerViewController.new;
        self.vc.player = player;
        
        [self.view addSubview:self.vc.view];
        [self addChildViewController:self.vc];
        [self.vc didMoveToParentViewController:self];
        [self.vc.player play];
    }
}

#pragma mark - Internal Methods
- (void)videoSaved:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"Save error"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Saved!"];
    }
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapInfo:(UIButton *)sender {
    UIStoryboard *chatStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    ActionsMenuViewController *actionsMenuVC = [chatStoryboard instantiateViewControllerWithIdentifier:@"ActionsMenuViewController"];
    actionsMenuVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentation = actionsMenuVC.popoverPresentationController;
    presentation.delegate = self;
    presentation.barButtonItem = self.navigationItem.rightBarButtonItem;
    presentation.permittedArrowDirections = 0;
    
    __weak __typeof(self) weakSelf = self;
    MenuAction *saveAttachmentAction = [[MenuAction alloc] initWithTitle:@"Save attachment" handler:^{
        __typeof(weakSelf)strongSelf = weakSelf;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    if ( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(strongSelf.videoURL.relativePath)) {
                        // Copy it to the camera roll.
                        UISaveVideoAtPathToSavedPhotosAlbum(strongSelf.videoURL.relativePath, strongSelf, @selector(videoSaved:didFinishSavingWithError:contextInfo:), nil);
                    } else {
                        [strongSelf showAlertWithTitle:@"Save error" message:@"Video is not compatible With Photos Album"
                                    fromViewController:self];
                        return;
                    }
                    break;
                case PHAuthorizationStatusDenied:
                    // Permission Denied
                    NSLog(@"User denied");
                    break;
                default:
                    NSLog(@"Restricted");
                    break;
            }
        }];
    }];
    
    [actionsMenuVC addAction:saveAttachmentAction];
    
    [self presentViewController:actionsMenuVC animated:NO completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
