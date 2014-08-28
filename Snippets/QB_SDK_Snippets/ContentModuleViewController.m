//
//  ContentModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/18/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ContentModuleViewController.h"
#import "ContentDataSource.h"


@interface ContentModuleViewController ()
@property (nonatomic) ContentDataSource *dataSource;
@property (nonatomic) QBCBlob *blobWithWriteAccess;
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

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[ContentDataSource alloc] init];
    tableView.dataSource = self.dataSource;
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
                    
                    if (useNewAPI) {
                        [QBRequest createBlob:blob successBlock:^(QBResponse *response, QBCBlob *blob) {
                            NSLog(@"Successfull response!");
                            
                            self.blobWithWriteAccess = blob;
                            
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent createBlob:blob delegate:self context:testContext];
                        }else{
                            [QBContent createBlob:blob delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get blob with ID
                case 1:{
                    
                    if (useNewAPI) {
                        [QBRequest blobWithID:164893 successBlock:^(QBResponse *response, QBCBlob *blob) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent blobWithID:164893 delegate:self context:testContext];
                        }else{
                            [QBContent blobWithID:164893 delegate:self];
                        }
                    }
                }
                    break;
                
                // Get blobs
                case 2:{
                    if (useNewAPI) {
                        if(withAdditionalRequest){
                            [QBRequest blobsForPage:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:5]
                                       successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
                                           NSLog(@"Blobs: %@", blobs);
                                       } errorBlock:^(QBResponse *response) {
                                           NSLog(@"Response error: %@", response.error);
                                       }];
                        } else {
                            [QBRequest blobsWithSuccessBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
                                NSLog(@"Successfull response!");
                            } errorBlock:^(QBResponse *response) {
                                NSLog(@"Response error: %@", response.error);
                            }];
                        }
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [[PagedRequest alloc] init];
                            pagedRequest.perPage = 2;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBContent blobsWithPagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBContent blobsWithPagedRequest:pagedRequest delegate:self];
                            }
                        }else{
                            [QBContent blobsWithDelegate:self];
                        }
                    }
                }
                    break;
                    
                // Get tagged blobs
                case 3:{
                    if (useNewAPI) {
                        if(withAdditionalRequest){
                            [QBRequest taggedBlobsForPage:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
                                NSLog(@"Successfull response!");
                            } errorBlock:^(QBResponse *response) {
                                NSLog(@"Response error: %@", response.error);
                            }];
                        } else {
                            [QBRequest taggedBlobsWithSuccessBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
                                NSLog(@"Successfull response!");
                            } errorBlock:^(QBResponse *response) {
                                NSLog(@"Response error: %@", response.error);
                            }];
                        }

                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [[PagedRequest alloc] init];
                            pagedRequest.perPage = 2;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBContent taggedBlobsWithPagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBContent taggedBlobsWithPagedRequest:pagedRequest delegate:self];
                            }
                        }else{
                            [QBContent taggedBlobsWithDelegate:self];
                        }
                    }
                }
                    break;
                    
                // Update blob
                case 4:{
                    QBCBlob *blob = [QBCBlob blob];
                    blob.ID = 215453;
                    blob.name = @"Myr";
                    blob.tags = @"man,car";
                    
                    if (useNewAPI) {
                        [QBRequest updateBlob:blob successBlock:^(QBResponse *response, QBCBlob *blob) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent updateBlob:blob delegate:self context:testContext];
                        }else{
                            [QBContent updateBlob:blob delegate:self];
                        }
                    }
                }
                    break;
                    
                // Delete blob with ID
                case 5:{
                    NSUInteger blobID = 215453;
                    
                    if (useNewAPI) {
                        [QBRequest deleteBlobWithID:blobID successBlock:^(QBResponse *response) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent deleteBlobWithID:blobID delegate:self context:testContext];
                        }else{
                            [QBContent deleteBlobWithID:blobID delegate:self];
                        }
                    }
                }
                    break;
                    
                // Complete blob with ID
                case 6:{
                    NSUInteger blobID = 215456;
                    NSUInteger size = 15783;
                    
                    if (useNewAPI) {
                        [QBRequest completeBlobWithID:blobID size:size successBlock:^(QBResponse *response) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent completeBlobWithID:blobID size:size delegate:self context:testContext];
                        }else{
                            [QBContent completeBlobWithID:blobID size:size delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get BlobObjectAccess with blob ID
                case 7:{
                    NSUInteger blobID = 215456;
                    if (useNewAPI) {
                        [QBRequest blobObjectAccessWithBlobID:blobID successBlock:^(QBResponse *response, QBCBlobObjectAccess *objectAccess) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent blobObjectAccessWithBlobID:blobID delegate:self context:testContext];
                        }else{
                            [QBContent blobObjectAccessWithBlobID:blobID delegate:self];
                        }
                    }
                }
                    break;
                    
                // Upload file
                case 8:{
                    NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"London" ofType:@"jpg"]];
                    //
                    // Note: 'blobWithWriteAccess' - you must obtain this object from 'createBlob' query result 
                    //
                    
                    if (useNewAPI) {
                        [QBRequest uploadFile:file blobWithWriteAccess:self.blobWithWriteAccess successBlock:^(QBResponse *response) {
                            NSLog(@"Successfull response!");
                        } statusBlock:nil errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                        
                    }else{
                        if(withQBContext){
                            [QBContent uploadFile:file blobWithWriteAccess:self.blobWithWriteAccess /* result.blob */ delegate:self context:testContext];
                        }else{
                            [QBContent uploadFile:file blobWithWriteAccess:self.blobWithWriteAccess /* result.blob */ delegate:self];
                        }
                    }
                }
                    break;
                    
                // Download file with UID
                case 9:{
                    NSString *uid = @"0f1042d7ed704cc289573c5a458175de00";
                    if (useNewAPI) {
                        [QBRequest downloadFileWithUID:uid successBlock:^(QBResponse *response, NSData *fileData) {
                            NSLog(@"Successfull response!");
                        } statusBlock:nil errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    }else{
                        if(withQBContext){
                            [QBContent downloadFileWithUID:uid delegate:self context:testContext];
                        }else{
                            [QBContent downloadFileWithUID:uid delegate:self];
                        }
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
                    NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"London" ofType:@"jpg"]];
                    
                    if (useNewAPI) {
                        [QBRequest TUploadFile:file fileName:@"Great Image" contentType:@"image/jpg" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
                            NSLog(@"Successfull response!");
                        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                            NSLog(@"upload progress: %f", status.percentOfCompletion);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent TUploadFile:file fileName:@"Great Image" contentType:@"image/jpg" isPublic:YES delegate:self context:testContext];
                        }else{
                            [QBContent TUploadFile:file fileName:@"Great Image" contentType:@"image/jpg" isPublic:YES delegate:self];
                        }
                    }
                }
                    break;
                    
                // TDownloadFileWithBlobID
                case 1:{
                    if (useNewAPI) {
                        QBRequest *request = [QBRequest TDownloadFileWithBlobID:215457 successBlock:^(QBResponse *response, NSData *fileData) {
                            NSLog(@"Successfull response!");
                        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                            NSLog(@"download progress: %f", status.percentOfCompletion);
                        }  errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent TDownloadFileWithBlobID:215457 delegate:self context:testContext];
                        }else{
                            [QBContent TDownloadFileWithBlobID:215457 delegate:self];
                        }
                    }
                }
                    break;
                    
                // TUpdateFile
                case 2:{
                    NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"London" ofType:@"jpg"]];
                    QBCBlob *blob = [QBCBlob blob];
                    blob.ID = 215457;
                    blob.name = @"London";
                    blob.contentType = @"image/jpg";
                    
                    if (useNewAPI) {
                        [QBRequest TUpdateFileWithData:file file:blob successBlock:^(QBResponse *response) {
                            NSLog(@"Successfull response!");;
                        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                            NSLog(@"upload progress: %f", status.percentOfCompletion);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBContent TUpdateFileWithData:file file:blob delegate:self context:testContext];
                        }else{
                            [QBContent TUpdateFileWithData:file file:blob delegate:self];
                        }
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

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
    if(result.success){
        
        // Get/Create/Update/Delete/Retain/Complete Blob result
        if([result isKindOfClass:QBCBlobResult.class]){
            QBCBlobResult *res = (QBCBlobResult *)result;
            NSLog(@"QBCBlobResult, blob=%@", res.blob);
            
            self.blobWithWriteAccess = res.blob;
        
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
            NSLog(@"QBCFileUploadTaskResult, uploadedBlob=%@", res.uploadedBlob.publicUrl);
            
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

-(void)setProgress:(float)progress{
     NSLog(@"setProgress %f", progress);
}

@end
