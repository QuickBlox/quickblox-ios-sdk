//
//  QBRequest+QBContent.h
//  Quickblox
//
//  Created by Andrey Moskvin on 6/5/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBCBlob;
@class QBCBlobObjectAccess;
@class QBGeneralResponsePage;
@interface QBRequest (QBContent)

#pragma mark -
#pragma mark Create Blob

/**
 Create blob.
 
 @param blob An instance of QBCBlob, describing the file to be uploaded.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */

+ (QBRequest *)createBlob:(QBCBlob *)blob successBlock:(void(^)(QBResponse *response, QBCBlob *blob))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get Blob with ID

/**
 Retrieve blob with ID.
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)blobWithID:(NSUInteger)blobID successBlock:(void(^)(QBResponse *response, QBCBlob *blob))successBlock
               errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get list of blobs for the current user

/**
 Get list of blob for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)blobsWithSuccessBlock:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs))successBlock
                          errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 Get list of blob for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)blobsForPage:(QBGeneralResponsePage *)page
               successBlock:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs))successBlock
                 errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get list of tagged blobs for the current user

/**
 Get list of tagged blobs for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)taggedBlobsWithSuccessBlock:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs))successBlock
                                errorBlock:(void(^)(QBResponse *response))errorBlock;
/**
 Get list of tagged blobs for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)taggedBlobsForPage:(QBGeneralResponsePage *)page
                     successBlock:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs))successBlock
                       errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Update Blob

/**
 Update Blob
 
 @param blob An instance of QBCBlob, describing the file to be updated.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateBlob:(QBCBlob*)blob successBlock:(void(^)(QBResponse *response, QBCBlob *blob))successBlock
                         errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Delete Blob with ID

/**
 Delete Blob
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteBlobWithID:(NSUInteger)blobID successBlock:(void(^)(QBResponse *response))successBlock
                     errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Declaring Blob uploaded with ID

/**
 Declaring Blob uploaded with ID
 
 Type of QBResult - QBResult
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param size Size of uploaded file, in bytes
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)completeBlobWithID:(NSUInteger)blobID size:(NSUInteger)size successBlock:(void(^)(QBResponse *response))successBlock
                       errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get File by ID as BlobObjectAccess

/**
 Get File by ID as BlobObjectAccess with read access
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
*/
+ (QBRequest *)blobObjectAccessWithBlobID:(NSUInteger)blobID
                             successBlock:(void(^)(QBResponse *response, QBCBlobObjectAccess *objectAccess))successBlock
                               errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Upload file using BlobObjectAccess

/**
 Upload file using BlobObjectAccess
 
 @param data File
 @param blobWithWriteAccess An instance of QBCBlobObjectAccess
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)uploadFile:(NSData *)data
      blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess
             successBlock:(void(^)(QBResponse *response))successBlock
              statusBlock:(QBRequestStatusUpdateBlock)statusBlock
               errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Download file

/**
 Download file
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)downloadFileWithUID:(NSString *)UID
                      successBlock:(void(^)(QBResponse *response, NSData *fileData))successBlock
                       statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                        errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Tasks

/**
 Upload File task. Contains 3 requests: Create Blob, upload file, declaring file uploaded
 
 @param data file to be uploaded
 @param fileName name of the file
 @param contentType type of the content in mime format
 @param isPublic blob's visibility
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)TUploadFile:(NSData*)data
                  fileName:(NSString*)fileName
               contentType:(NSString*)contentType
                  isPublic:(BOOL)isPublic
              successBlock:(void(^)(QBResponse *response, QBCBlob* blob))successBlock
               statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 Download File task. Contains 2 requests: Get Blob with ID, download file

 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */

+ (QBRequest *)TDownloadFileWithBlobID:(NSUInteger)blobID
                          successBlock:(void(^)(QBResponse *response, NSData *fileData))successBlock
                           statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                            errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 Update File task. Contains 3 quieries: Update Blob, Upload file, Declaring file uploaded
 
 @param data file to be uploaded
 @param blob file which need to be updated
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */

+ (QBRequest *)TUpdateFileWithData:(NSData *)data
                              file:(QBCBlob *)file
                      successBlock:(void(^)(QBResponse *response))successBlock
                       statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                        errorBlock:(void(^)(QBResponse *response))errorBlock;

@end
