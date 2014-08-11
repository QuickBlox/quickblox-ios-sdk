//
//  MainViewController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#define IMAGE_WIDTH 100
#define IMAGE_HEIGHT 100
#define START_POSITION_X 5
#define START_POSITION_Y 10
#define MARGING 5
#define IMAGES_IN_ROW 3

#import "SSCMainViewController.h"
#import "SSCPhotoViewController.h"

@interface SSCMainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBActionStatusDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImagePickerController* imagePicker;

@end

@implementation SSCMainViewController {
    int currentImageX;
    int currentImageY;
    int picturesInRowCounter;
    
    NSMutableArray* imageViews;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentImageX = START_POSITION_X;
        currentImageY = START_POSITION_Y;
        picturesInRowCounter = 0;
        imageViews = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Content";
    
    CGRect appframe = [[UIScreen mainScreen] bounds];
    [self.scrollView setContentSize:appframe.size];
    [self.scrollView setMaximumZoomScale:4];
    
    // Show toolbar
    UIBarButtonItem* uploadItem = [[UIBarButtonItem alloc] initWithTitle:@"Add new image" style:(UIBarButtonItemStyle)UIBarButtonSystemItemAdd  target:self action:@selector(selectPicture)];
    self.navigationItem.rightBarButtonItem = uploadItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[SSCContentManager instance] imageArrayIsEmpty]) {
        
        // Download user's files
        [self downloadFile];
        
        [self.activityIndicator startAnimating];
    }
}

#pragma mark -
#pragma mark Core

- (void)downloadFile
{
    NSString *fileID = [[[SSCContentManager instance] lastObjectFromFileList] UID];
    if (fileID > 0) {
        // Download file from QuickBlox server
        [QBRequest downloadFileWithUID:fileID successBlock:^(QBResponse *response, NSData *fileData) {
            if ( fileData ) {
                
                // Add image to gallery
                [[SSCContentManager instance] savePicture:[UIImage imageWithData: fileData]];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:fileData]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self showImage:imageView];
                //
                [[SSCContentManager instance] removeLastObjectFromFileList];
                
                // Download next file
                [self downloadFile];
            } else {
                [[SSCContentManager instance] removeLastObjectFromFileList];
                
                // download next file
                [self downloadFile];
            }
        } errorBlock:^(QBResponse *response) {
            
        }];
        
    }
    
    // end of files
    if ([[SSCContentManager instance] fileListIsEmpty]) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}

// Show image on your gallery
-(void)showImage:(UIImageView*) image
{
    image.frame = CGRectMake(currentImageX, currentImageY, IMAGE_WIDTH, IMAGE_HEIGHT);
    image.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreenPicture:)];
    [image addGestureRecognizer:tapRecognizer];
    
    [self.scrollView addSubview:image];
    currentImageX += IMAGE_WIDTH;
    currentImageX += MARGING; // distance between two images
    picturesInRowCounter++;
    
    if (picturesInRowCounter == IMAGES_IN_ROW) {
        currentImageX = START_POSITION_X;
        currentImageY += IMAGE_HEIGHT;
        currentImageY += MARGING;
        picturesInRowCounter = 0;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)showFullScreenPicture:(id)sender
{
    UITapGestureRecognizer* tapRecognizer = (UITapGestureRecognizer*)sender;
    UIImageView* selectedImageView = (UIImageView*)[tapRecognizer view];
    SSCPhotoViewController* photoController = [SSCPhotoViewController new];
    photoController.photoImage = selectedImageView.image;
    [self.navigationController pushViewController:photoController animated:YES];
}

// Show Picker for select picture from iPhone gallery to add to your gallery
- (void)selectPicture
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// when photo is selected from gallery - > upload it to server
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData* imageData = UIImagePNGRepresentation(selectedImage);
    
    // Show image on gallery
    UIImageView* imageView = [[UIImageView alloc] initWithImage:selectedImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self showImage:imageView];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    // Show progress
    QBRequestStatusUpdateBlock block = ^(QBRequest *request, QBRequestStatus *status) {
        NSLog(@"%f", status.percentOfCompletion);
    };
    // Upload file to QuickBlox server

    QBRequest *req = [QBRequest TUploadFile:imageData fileName:@"Great Image" contentType:@"image/png" isPublic:NO successBlock:nil errorBlock:nil];
    req.updateBlock = block;}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
