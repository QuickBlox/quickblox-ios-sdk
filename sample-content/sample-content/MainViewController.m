//
//  ViewController.m
//  sample-content
//
//  Created by Igor Khomenko on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "MainViewController.h"
#import "ContentViewController.h"
#import "Storage.h"
#import "FilesPaginator.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD.h>

@interface MainViewController ()  <UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) FilesPaginator *paginator;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

// OpenImageSegueIdentifier

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paginator = [[FilesPaginator alloc] initWithPageSize:10 delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self setupTableViewFooter];
        
        [SVProgressHUD showWithStatus:@"Downloading images"];
        
        // Your app connects to QuickBlox server here.
        //
        
        [QBRequest logInWithUserLogin:@"igorquickblox2" password:@"igorquickblox2" successBlock:^(QBResponse *response, QBUUser *user) {
            // Load files
            //
            [self.paginator fetchFirstPage];
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Response error %@:", response.error);
        }];
        
    });
}

- (IBAction)addNewPicture:(id)sender{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark
#pragma mark Paginator

- (void)fetchNextPage
{
    [self.paginator fetchNextPage];
    [self.activityIndicator startAnimating];
}

- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.tableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if ([self.paginator.results count] != 0){
        self.footerLabel.text = [NSString stringWithFormat:@"%lu results out of %ld",
                                 (unsigned long)[self.paginator.results count], (long)self.paginator.total];
    }else{
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}

#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender{
    if([segue.destinationViewController isKindOfClass:ContentViewController.class]){
        
        NSUInteger row = sender.tag;
        QBCBlob *file = [Storage instance].filesList[row];
        
        ContentViewController *destinationViewController = (ContentViewController *)segue.destinationViewController;
        destinationViewController.file = file;
    }
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height){
        // ask next page only if we haven't reached last page
        if(![self.paginator reachedLastPage]){
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[Storage instance].filesList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCellIdentifier"];
    cell.tag = indexPath.row;
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:201];
    UIActivityIndicatorView *progressView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
    
    // Load the image
    //
    QBCBlob *file = [Storage instance].filesList[indexPath.row];
    NSString *privateUrl = [file privateUrl];
    if(privateUrl){
        [progressView startAnimating];
        [imageView sd_setImageWithURL:[NSURL URLWithString:privateUrl]
                      placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          [progressView stopAnimating];
                      }];
    }else{
        NSLog(@"Private URL is NULL");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


#pragma mark
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    // save files
    //
    [[Storage instance].filesList addObjectsFromArray:results];
    
    // update tableview footer
    [self updateTableViewFooter];
    [self.activityIndicator stopAnimating];
    
    // reload table
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// when photo is selected from gallery - > upload it to server
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(selectedImage);

    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    // Upload file to QuickBlox cloud
    //
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"Uploading image"];
    [QBRequest TUploadFile:imageData fileName:@"iOS Content-Sample image" contentType:@"image/png" isPublic:NO
              successBlock:^(QBResponse *response, QBCBlob *blob) {
                  [SVProgressHUD dismiss];
                  
                  // save it
                  [[Storage instance].filesList addObject:blob];
                  
                  [weakSelf.tableView reloadData];
                  [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[Storage instance].filesList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                  
              }statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                  [SVProgressHUD showProgress:status.percentOfCompletion status:@"Uploading image"];
              }errorBlock:^(QBResponse *response) {
                  [SVProgressHUD dismiss];
                  //
                  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error while uploading new file"
                                                                  message:[response.error description]
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
                  [alert show];
              }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
