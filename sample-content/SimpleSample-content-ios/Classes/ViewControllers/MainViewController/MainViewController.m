//
//  MainViewController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoViewController.h"
@interface MainViewController ()

@end

@implementation MainViewController
@synthesize scroll;
@synthesize activityIndicator;
@synthesize imagePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentImageX = START_POSITION_X;
        currentImageY = START_POSITION_Y;
        picturesInRowCounter = 0;
        imageViews = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    CGRect appframe = [[UIScreen mainScreen] bounds];
    [scroll setContentSize:appframe.size];
    [scroll setMaximumZoomScale:4];
    
    // Show toolbar
    UIBarButtonItem* uploadItem = [[UIBarButtonItem alloc] initWithTitle:@"Add new image" style:(UIBarButtonItemStyle)UIBarButtonSystemItemAdd  target:self action:@selector(selectPicture)];
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    if(IS_HEIGHT_GTE_568){
        toolbar.frame = CGRectMake(0, self.view.frame.size.height+1, self.view.frame.size.width, 44);
    }else{
        toolbar.frame = CGRectMake(0, self.view.frame.size.height-87, self.view.frame.size.width, 44);
    }
    if(QB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        toolbar.frame = CGRectMake(toolbar.frame.origin.x, toolbar.frame.origin.y-20, toolbar.frame.size.width, toolbar.frame.size.height);
    }
    [toolbar setItems:[NSArray arrayWithObject:uploadItem]];
    [self.view addSubview:toolbar];
}

-(void)viewDidAppear:(BOOL)animated{
    if (![[DataManager instance] images]) {
        
        // Download user's files
        [self downloadFile];
        
        [activityIndicator startAnimating];
        
        return;
    }    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Core

-(void)downloadFile{
    NSUInteger fileID = [(QBCBlob *)[[[DataManager instance] fileList] lastObject] ID];
    if(fileID > 0){
        // Download file from QuickBlox server
        [QBContent TDownloadFileWithBlobID:fileID delegate:self];
    }
    
    // end of files
    if ([[DataManager instance] fileList].count == 0) {
        [activityIndicator stopAnimating];
        activityIndicator.hidden = YES;
    }
}

// Show image on your gallery
-(void)showImage:(UIImageView*) image{
    image.frame = CGRectMake(currentImageX, currentImageY, IMAGE_WIDTH, IMAGE_HEIGHT);
    image.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreenPicture:)];
    [image addGestureRecognizer:tapRecognizer];
    
    [scroll addSubview:image];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)showFullScreenPicture:(id)sender{
    UITapGestureRecognizer* tapRecognizer = (UITapGestureRecognizer*)sender;
    UIImageView* selectedImageView = (UIImageView*)[tapRecognizer view];
    PhotoViewController* photoController = [[PhotoViewController alloc] initWithImage:selectedImageView.image];
    [self.navigationController pushViewController:photoController animated:YES];
}

// Show Picker for select picture from iPhone gallery to add to your gallery
-(void)selectPicture{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// when photo is selected from gallery - > upload it to server
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData* imageData = UIImagePNGRepresentation(selectedImage);
    
    // Show image on gallery
    UIImageView* imageView = [[UIImageView alloc] initWithImage:selectedImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self showImage:imageView];
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    
    // Upload file to QuickBlox server
    [QBContent TUploadFile:imageData fileName:@"Great Image" contentType:@"image/png" isPublic:NO delegate:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result{
    
    // Download file result
    if ([result isKindOfClass:QBCFileDownloadTaskResult.class]) {
        
        // Success result
        if (result.success) {
            
            QBCFileDownloadTaskResult *res = (QBCFileDownloadTaskResult *)result;
            if ([res file]) {   
                
                // Add image to gallery
                [[DataManager instance] savePicture:[UIImage imageWithData:[res file]]];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[res file]]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self showImage:imageView];
                //
                [[[DataManager instance] fileList] removeLastObject];
                
                // Download next file
                [self downloadFile];
            }          
        }else{
            [[[DataManager instance] fileList] removeLastObject];
            
            // download next file
            [self downloadFile];
        }
    }
}

-(void)setProgress:(float)progress{
    NSLog(@"progress: %f", progress);
}

@end
