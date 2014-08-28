//
//  RichContentViewController.m
//  SimpleSample Messages
//
//  Created by Ruslan on 9/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSMRichContentViewController.h"
#import "SSMPushMessage.h"

@interface SSMRichContentViewController () <QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *downloadProgress;

@end

@implementation SSMRichContentViewController {
    int imageNumber;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageNumber = 0;
    
    // Download rich content
    for (NSString *fileID in self.message.richContentFilesIDs) {
        [self.downloadProgress startAnimating];
        QBRequest* request = [QBRequest TDownloadFileWithBlobID:[fileID intValue] successBlock:^(QBResponse *response, NSData *fileData) {
            // show image
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, imageNumber * 420, 320, 420)];
            [imageView setBackgroundColor:[UIColor clearColor]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageWithData:fileData];
            
            [self.scrollView setContentSize:CGSizeMake(320, 420 * (imageNumber + 1))];
            [self.scrollView addSubview:imageView];
            
            ++imageNumber;
            
            if (imageNumber == [self.message.richContentFilesIDs count]) {
                [self.downloadProgress stopAnimating];
            }
        } statusBlock:nil errorBlock:^(QBResponse *response) {
            NSLog(@"Error while downloading rich push:%@", [response.error description]);
        }];
        
        request.updateBlock = ^(QBRequest* request, QBRequestStatus* status){
            _progressView.progress = status.percentOfCompletion;
            if (status.percentOfCompletion == 1) {
                _progressView.hidden = YES;
            }
        };
    }
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result
{
    // Download rich content result
    if ([result isKindOfClass:[QBCFileDownloadTaskResult class]]) {
        QBCFileDownloadTaskResult *res = (QBCFileDownloadTaskResult *)result;
        
        // Success result
        if (res.success) {
            // show image
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, imageNumber * 420, 320, 420)];
            [imageView setBackgroundColor:[UIColor clearColor]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageWithData:res.file];
            
            [self.scrollView setContentSize:CGSizeMake(320, 420 * (imageNumber + 1))];
            [self.scrollView addSubview:imageView];
            
            ++imageNumber;
            
            if (imageNumber == [self.message.richContentFilesIDs count]) {
                [self.downloadProgress stopAnimating];
            }
        }
    }
}

- (void)setProgress:(float)progress
{
    _progressView.progress = progress;
    if (progress == 1) {
        _progressView.hidden = YES;
    }
}

@end
