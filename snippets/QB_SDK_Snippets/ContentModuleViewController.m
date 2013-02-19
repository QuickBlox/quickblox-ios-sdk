//
//  ContentModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/18/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ContentModuleViewController.h"

@interface ContentModuleViewController ()

@end

@implementation ContentModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Content", @"Content");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 11;
        case 1:
            return 2;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Blobs";
            
        case 1:
            return @"Tasks";
            
        default:
            break;
    }
    
    
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    switch (indexPath.section) {
        // Blobs
        case 0:
            switch (indexPath.row) {
                // Create blob
                case 0:{
                    QBCBlob *blob = [QBCBlob blob];
                    blob.name = @"My File";
                    blob.contentType = @"image/png";
                    
                    if(withContext){
                        [QBContent createBlob:blob delegate:self context:testContext];
                    }else{
                        [QBContent createBlob:blob delegate:self];
                    }
                }
                    break;
                    
                // Get blob with ID
                case 1:{
                    if(withContext){
                        [QBContent blobWithID:910 delegate:self context:testContext];
                    }else{
                        [QBContent blobWithID:910 delegate:self];
                    }
                }
                    break;
                
                // Get blobs
                case 2:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
                        pagedRequest.perPage = 2;
                        pagedRequest.page = 1;
                        
                        if(withContext){
                            [QBContent blobsWithPagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBContent blobsWithPagedRequest:pagedRequest delegate:self];
                        }
                        
                        [pagedRequest release];
                    }else{
                        [QBContent blobsWithDelegate:self];
                    }
                }
                    break;
                    
                // Get tagged blobs
                case 3:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
                        pagedRequest.perPage = 2;
                        pagedRequest.page = 1;
                        
                        if(withContext){
                            [QBContent taggedBlobsWithPagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBContent taggedBlobsWithPagedRequest:pagedRequest delegate:self];
                        }
                        
                        [pagedRequest release];
                    }else{
                        [QBContent taggedBlobsWithDelegate:self];
                    }
                }
                    break;
                    
                // Update blob
                case 4:{
                    QBCBlob *blob = [QBCBlob blob];
                    blob.ID = 904;
                    blob.name = @"My Image File";
                    blob.tags = @"man,car";
                    
                    if(withContext){
                        [QBContent updateBlob:blob delegate:self context:testContext];
                    }else{
                        [QBContent updateBlob:blob delegate:self];
                    }
                }
                    break;
                    
                // Delete blob with ID
                case 5:{
                    if(withContext){
                        [QBContent deleteBlobWithID:905 delegate:self context:testContext];
                    }else{
                        [QBContent deleteBlobWithID:905 delegate:self]; 
                    }
                }
                    break;
                    
                // Retain blob with ID
                case 6:{
                    if(withContext){
                        [QBContent retainBlobWithID:910 delegate:self context:testContext];
                    }else{
                        [QBContent retainBlobWithID:910 delegate:self]; 
                    }
                }
                    break;
                    
                // Complete blob with ID
                case 7:{
                    if(withContext){
                        [QBContent completeBlobWithID:910 size:15783 delegate:self context:testContext];
                    }else{
                        [QBContent completeBlobWithID:910 size:15783 delegate:self]; 
                    }
                }
                    break;
                    
                // Get BlobObjectAccess with blob ID
                case 8:{
                    if(withContext){
                        [QBContent blobObjectAccessWithBlobID:1161 delegate:self context:testContext];
                    }else{
                        [QBContent blobObjectAccessWithBlobID:1161 delegate:self]; 
                    }
                }
                    break;
                    
                // Upload file
                case 9:{
                    NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"YellowStar" ofType:@"png"]];
                    //
                    // Note: 'blobWithWriteAccess' - you must obtain this object from 'createBlob' query result 
                    //
                    if(withContext){
                        [QBContent uploadFile:file blobWithWriteAccess:nil /* result.blob */ delegate:self context:testContext];
                    }else{
                        [QBContent uploadFile:file blobWithWriteAccess:nil /* result.blob */ delegate:self]; 
                    }
                }
                    break;
                    
                // Download file with UID
                case 10:{
                    if(withContext){
                        [QBContent downloadFileWithUID:@"a75ebcd6ce8a4bc4a36f8c3600e254fb00" delegate:self context:testContext];
                    }else{
                        [QBContent downloadFileWithUID:@"a75ebcd6ce8a4bc4a36f8c3600e254fb00" delegate:self];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
            // Tasks
        case 1:
            switch (indexPath.row) {
                // TUploadFile
                case 0:{
                    NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"YellowStar" ofType:@"png"]];
                    
                    if(withContext){
                        [QBContent TUploadFile:file fileName:@"Great Image" contentType:@"image/png" isPublic:YES delegate:self context:testContext];
                    }else{
                        [QBContent TUploadFile:file fileName:@"Great Image" contentType:@"image/png" isPublic:YES delegate:self];
                    }
                }
                    break;
                    
                // TDownloadFileWithBlobID
                case 1:{
                    if(withContext){
                        [QBContent TDownloadFileWithBlobID:6281 delegate:self context:testContext];
                    }else{
                        [QBContent TDownloadFileWithBlobID:6281 delegate:self];
                    }
                }
                    break;
                default:
                    break;
            }
            
            break;
        default:
            break;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        // Blobs
        case 0:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create blob";
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"Get blob with ID";
                }
                    break;
                case 2:{
                    cell.textLabel.text = @"Get blobs";
                    break;
                }
                case 3:{
                    cell.textLabel.text = @"Get tagged blobs";
                }
                    break;
                case 4:{
                    cell.textLabel.text = @"Update blob";
                }
                    break;
                case 5:{
                    cell.textLabel.text = @"Delete blob with ID";
                }
                    break;
                case 6:{
                    cell.textLabel.text = @"Retain blob with ID";
                }
                    break;
                case 7:{
                    cell.textLabel.text = @"Complete blob with ID";
                }
                    break;
                case 8:{
                    cell.textLabel.text = @"Get BlobObjectAccess with blob ID";
                }
                    break;
                case 9:{
                    cell.textLabel.text = @"Upload file";
                }
                    break;
                case 10:{
                    cell.textLabel.text = @"Download file with UID";
                }
                    break;

                default:
                    break;
            }
            break;
            
        // Tasks
        case 1:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"TUploadFile";
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"TDownloadFileWithBlobID";
                }
                    break;
                default:
                    break;
            }

            break;
        default:
            break;
    }    
    return cell;
}

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
    if(result.success){
        
        // Get/Create/Update/Delete/Retain/Complete Blob result
        if([result isKindOfClass:QBCBlobResult.class]){
            QBCBlobResult *res = (QBCBlobResult *)result;
            NSLog(@"QBCBlobResult, blob=%@", res.blob); 
        
        // Get Blobs result
        }else if([result isKindOfClass:QBCBlobPagedResult.class]){
            QBCBlobPagedResult *res = (QBCBlobPagedResult *)result;
            NSLog(@"QBBBlobPagedResult, blobs=%@", res.blobs);
        
        // Get BlobObjectAccess result
        }else if([result isKindOfClass:QBCBlobObjectAccessResult.class]){
            QBCBlobObjectAccessResult *res = (QBCBlobObjectAccessResult *)result;
            NSLog(@"QBCBlobObjectAccessResult, blobObjectAccess=%@", res.blobObjectAccess);
        
        // Get Download file result
        }else if([result isKindOfClass:QBCFileResult.class]){
            QBCFileResult *res = (QBCFileResult *)result;
            NSLog(@"QBCFileResult, file=%@", res.data);
        
        // Upload file task result
        }else if([result isKindOfClass:QBCFileUploadTaskResult.class]){
            QBCFileUploadTaskResult *res = (QBCFileUploadTaskResult *)result;
            NSLog(@"QBCFileUploadTaskResult, uploadedBlob=%@", res.uploadedBlob);
            
        // Download file task result
        }else if([result isKindOfClass:QBCFileDownloadTaskResult.class]){
            QBCFileDownloadTaskResult *res = (QBCFileDownloadTaskResult *)result;
            NSLog(@"QBCFileDownloadTaskResult, file=%@", res.file);
            
        // Upload file result
        }else{
            NSLog(@"Result");
        }
        
    }else{
        NSLog(@"Errors=%@", result.errors); 
    }
}

// QuickBlox queries delegate (with context)
- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}


@end
