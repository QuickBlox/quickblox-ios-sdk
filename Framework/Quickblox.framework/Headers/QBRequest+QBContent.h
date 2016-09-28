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

NS_ASSUME_NONNULL_BEGIN

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
+ (QBRequest *)createBlob:(QBCBlob *)blob
                        successBlock:(nullable void(^)(QBResponse *response, QBCBlob * _Nullable blob))successBlock
                          errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get Blob with ID

/**
 Retrieve blob with ID.
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobWithID:(NSUInteger)blobID
                        successBlock:(nullable void(^)(QBResponse *response, QBCBlob * _Nullable blob))successBlock
                          errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get list of blobs for the current user

/**
 Get list of blob for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobsWithSuccessBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBCBlob *) * _Nullable blobs))successBlock
                                     errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

/**
 Get list of blob for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobsForPage:(nullable QBGeneralResponsePage *)page
                          successBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray QB_GENERIC(QBCBlob *) * _Nullable blobs))successBlock
                            errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get list of tagged blobs for the current user

/**
 Get list of tagged blobs for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)taggedBlobsWithSuccessBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray QB_GENERIC(QBCBlob *) * _Nullable blobs))successBlock
                                           errorBlock:(nullable void(^)(QBResponse *response))errorBlock;
/**
 Get list of tagged blobs for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)taggedBlobsForPage:(nullable QBGeneralResponsePage *)page
                                successBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray QB_GENERIC(QBCBlob *) * _Nullable blobs))successBlock
                                  errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Update Blob

/**
 Update Blob
 
 @param blob An instance of QBCBlob to be updated.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateBlob:(QBCBlob *)blob
                        successBlock:(nullable void(^)(QBResponse *response, QBCBlob *blob))successBlock
                          errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Delete Blob with ID

/**
 Delete Blob
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteBlobWithID:(NSUInteger)blobID
                              successBlock:(nullable void(^)(QBResponse *response))successBlock
                                errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

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
+ (QBRequest *)completeBlobWithID:(NSUInteger)blobID
                                        size:(NSUInteger)size
                                successBlock:(nullable void(^)(QBResponse *response))successBlock
                                  errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Get File by ID as BlobObjectAccess

/**
 Get File by ID as BlobObjectAccess with read access
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobObjectAccessWithBlobID:(NSUInteger)blobID
                                        successBlock:(nullable void(^)(QBResponse *response, QBCBlobObjectAccess * _Nullable objectAccess))successBlock
                                          errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

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
+ (QBRequest *)uploadFile:(nullable NSData *)data
                 blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess
                        successBlock:(nullable void(^)(QBResponse *response))successBlock
                         statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                          errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

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
+ (QBRequest *)downloadFileWithUID:(NSString *)UID
                                 successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                                  statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                                   errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

/**
 Download file using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)backgroundDownloadFileWithUID:(NSString *)UID
                                           successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                                            statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                                             errorBlock:(nullable void(^)(QBResponse *response))errorBlock;
/**
 Download File by file identifier.
 
 @param fileID File identifier.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)downloadFileWithID:(NSUInteger)fileID
                                successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                                 statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                                  errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

/**
 Download File by file identifier using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param fileID File identifier.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)backgroundDownloadFileWithID:(NSUInteger)fileID
                                          successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                                           statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                                            errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

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
+ (QBRequest *)TUploadFile:(NSData *)data
                             fileName:(NSString *)fileName
                          contentType:(NSString *)contentType
                             isPublic:(BOOL)isPublic
                         successBlock:(nullable void(^)(QBResponse *response, QBCBlob *blob))successBlock
                          statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                           errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

/**
 Update File task. Contains 3 quieries: Update Blob, Upload file, Declaring file uploaded
 
 @param data File to be uploaded
 @param file File which needs to be updated
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)TUpdateFileWithData:(nullable NSData *)data
                                         file:(QBCBlob *)file
                                 successBlock:(nullable void(^)(QBResponse *response))successBlock
                                  statusBlock:(nullable QBRequestStatusUpdateBlock)statusBlock
                                   errorBlock:(nullable void(^)(QBResponse *response))errorBlock;

@end

NS_ASSUME_NONNULL_END
