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

- (void)dealloc {
    [imageViews release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    CGRect appframe = [[UIScreen mainScreen] bounds];
    [scroll setContentSize:appframe.size];
    [scroll setMaximumZoomScale:4];
    
    // Show toolbar
    UIBarButtonItem* uploadItem = [[UIBarButtonItem alloc] initWithTitle:@"Add new image" style:UIBarButtonSystemItemAdd  target:self action:@selector(selectPicture)];
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    if(IS_HEIGHT_GTE_568){
        toolbar.frame = CGRectMake(0, self.view.frame.size.height+1, self.view.frame.size.width, 44);
    }else{
        toolbar.frame = CGRectMake(0, self.view.frame.size.height-87, self.view.frame.size.width, 44);
    }
    
    [toolbar setItems:[NSArray arrayWithObject:uploadItem]];
    [uploadItem release];
    [self.view addSubview:toolbar];
    [toolbar release];
}

-(void)viewDidAppear:(BOOL)animated{
    if (![[DataManager instance] images]) {
        
        // Download user's files
        [self downloadFile];
        
        [activityIndicator startAnimating];
        
        return;
    }    
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setScroll:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Core

-(void)downloadFile{
    int fileID = [(QBCBlob *)[[[DataManager instance] fileList] lastObject] ID];
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
    [tapRecognizer release];
    
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
    [photoController release];
}

// Show Picker for select picture from iPhone gallery to add to your gallery
-(void)selectPicture{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:imagePicker animated:NO];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// when photo is selected from gallery - > upload it to server
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];   
    NSData* imageData = UIImagePNGRepresentation(selectedImage);
    
    // Show image on gallery
    UIImageView* imageView = [[UIImageView alloc] initWithImage:selectedImage];
    [self showImage:imageView];
    [imageView release];
    [imagePicker dismissModalViewControllerAnimated:NO];
    [imagePicker release];
    
    
    // Upload file to QuickBlox server
    [QBContent TUploadFile:imageData fileName:@"Great Image" contentType:@"image/png" isPublic:NO delegate:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [imagePicker dismissModalViewControllerAnimated:NO];
    [imagePicker release];
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
                [self showImage:imageView];
                [imageView release];
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

@end
