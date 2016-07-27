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
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createBlob:(QB_NONNULL QBCBlob *)blob
                        successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBCBlob * QB_NULLABLE_S blob))successBlock
                          errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Get Blob with ID

/**
 Retrieve blob with ID.
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)blobWithID:(NSUInteger)blobID
                        successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBCBlob * QB_NULLABLE_S blob))successBlock
                          errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Get list of blobs for the current user

/**
 Get list of blob for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)blobsWithSuccessBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBCBlob *) * QB_NULLABLE_S blobs))successBlock
                                     errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Get list of blob for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)blobsForPage:(QB_NULLABLE QBGeneralResponsePage *)page
                          successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NONNULL_S page, NSArray QB_GENERIC(QBCBlob *) * QB_NULLABLE_S blobs))successBlock
                            errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Get list of tagged blobs for the current user

/**
 Get list of tagged blobs for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)taggedBlobsWithSuccessBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NONNULL_S page, NSArray QB_GENERIC(QBCBlob *) * QB_NULLABLE_S blobs))successBlock
                                           errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Get list of tagged blobs for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)taggedBlobsForPage:(QB_NULLABLE QBGeneralResponsePage *)page
                                successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NONNULL_S page, NSArray QB_GENERIC(QBCBlob *) * QB_NULLABLE_S blobs))successBlock
                                  errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Update Blob

/**
 Update Blob
 
 @param blob An instance of QBCBlob to be updated.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateBlob:(QB_NONNULL QBCBlob *)blob
                        successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBCBlob * QB_NONNULL_S blob))successBlock
                          errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Delete Blob with ID

/**
 Delete Blob
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteBlobWithID:(NSUInteger)blobID
                              successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                                errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Declaring Blob uploaded with ID

/**
 Declaring Blob uploaded with ID
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param size Size of uploaded file, in bytes
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)completeBlobWithID:(NSUInteger)blobID
                                        size:(NSUInteger)size
                                successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                                  errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Get File by ID as BlobObjectAccess

/**
 Get File by ID as BlobObjectAccess with read access
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)blobObjectAccessWithBlobID:(NSUInteger)blobID
                                        successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBCBlobObjectAccess * QB_NULLABLE_S objectAccess))successBlock
                                          errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Upload file using BlobObjectAccess

/**
 Upload file using BlobObjectAccess
 
 @param data File
 @param blobWithWriteAccess An instance of QBCBlobObjectAccess
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)uploadFile:(QB_NULLABLE NSData *)data
                 blobWithWriteAccess:(QB_NONNULL QBCBlob *)blobWithWriteAccess
                        successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                         statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                          errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Download file

/**
 Download file
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)downloadFileWithUID:(QB_NONNULL NSString *)UID
                                 successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSData * QB_NONNULL_S fileData))successBlock
                                  statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                                   errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Download file using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)backgroundDownloadFileWithUID:(QB_NONNULL NSString *)UID
                                           successBlock:(QB_NULLABLE void(^)(QBResponse *QB_NONNULL_S response, NSData *QB_NONNULL_S fileData))successBlock
                                            statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                                             errorBlock:(QB_NULLABLE void(^)(QBResponse *QB_NONNULL_S response))errorBlock;
/**
 Download File by file identifier.
 
 @param fileID File identifier.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)downloadFileWithID:(NSUInteger)fileID
                                successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSData * QB_NONNULL_S fileData))successBlock
                                 statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                                  errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Download File by file identifier using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param fileID File identifier.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)backgroundDownloadFileWithID:(NSUInteger)fileID
                                          successBlock:(QB_NULLABLE void(^)(QBResponse *QB_NONNULL_S response, NSData *QB_NONNULL_S fileData))successBlock
                                           statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                                            errorBlock:(QB_NULLABLE void(^)(QBResponse *QB_NONNULL_S response))errorBlock;

#pragma mark -
#pragma mark Tasks

/**
 Upload File task. Contains 3 requests: Create Blob, upload file, declaring file uploaded
 
 @param data File to be uploaded
 @param fileName Name of the file
 @param contentType Type of the content in mime format
 @param isPublic Blob's visibility
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)TUploadFile:(QB_NONNULL NSData *)data
                             fileName:(QB_NONNULL NSString *)fileName
                          contentType:(QB_NONNULL NSString *)contentType
                             isPublic:(BOOL)isPublic
                         successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBCBlob * QB_NONNULL_S blob))successBlock
                          statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                           errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Update File task. Contains 3 quieries: Update Blob, Upload file, Declaring file uploaded
 
 @param data File to be uploaded
 @param file File which needs to be updated
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)TUpdateFileWithData:(QB_NULLABLE NSData *)data
                                         file:(QB_NONNULL QBCBlob *)file
                                 successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                                  statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                                   errorBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))errorBlock;

@end
