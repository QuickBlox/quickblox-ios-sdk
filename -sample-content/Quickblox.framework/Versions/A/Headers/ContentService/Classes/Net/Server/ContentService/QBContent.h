//
//  QBContent.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


/** QBContent class declaration. */
/** Overview */
/** This class is the main entry point to work with cloud stored files. */

@interface QBContent : BaseService {
    
}


#pragma mark -
#pragma mark Create Blob

/** 
 Create blob. 
 
 Type of Result - QBCBlobResult
 
 @param blob An instance of QBCBlob, describing the file to be uploaded.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCBlobResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)createBlob:(QBCBlob*)blob delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)createBlob:(QBCBlob*)blob delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Blob with ID

/** 
 Retrieve blob with ID.
 
 Type of Result - QBCBlobResult
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of QBCBlobResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */ 
+ (NSObject<Cancelable>*)blobWithID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)blobWithID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Get list of blobs for the current user

/**
 Get list of blob for the current User (last 10 files, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBCBlobPagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCBlobPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)blobsWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)blobsWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;

/**
 Get list of blob for the current User (with extended set of pagination parameters)
 
 Type of Result - QBCBlobPagedResult
 
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)blobsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)blobsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Get list of tagged blobs for the current user

/**
 Get list of tagged blobs for the current User (last 10 files, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBCBlobPagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCBlobPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)taggedBlobsWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)taggedBlobsWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;

/**
 Get list of tagged blobs for the current User (with extended set of pagination parameters)
 
 Type of Result - QBCBlobPagedResult
 
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)taggedBlobsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)taggedBlobsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Update Blob

/** 
 Update Blob
 
 Type of Result - QBCBlobResult

 @param blob An instance of QBCBlob, describing the file to be updated.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of QBCBlobResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */ 
+ (NSObject<Cancelable>*)updateBlob:(QBCBlob*)blob delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)updateBlob:(QBCBlob*)blob delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete Blob with ID

/** 
 Delete Blob
 
 Type of Result - Result
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)deleteBlobWithID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)deleteBlobWithID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Increasing a number of the links to the file

/** 
 Increasing a number of the links to the file
 
 Type of Result - Result
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)retainBlobWithID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)retainBlobWithID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Declaring Blob uploaded with ID

/** 
 Declaring Blob uploaded with ID
 
 Type of Result - Result
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param size Size of uploaded file, in bytes
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)completeBlobWithID:(NSUInteger)blobID size:(NSUInteger)size delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)completeBlobWithID:(NSUInteger)blobID size:(NSUInteger)size delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Get File by ID as BlobObjectAccess

/** 
 Get File by ID as BlobObjectAccess with read access
 
 Type of Result - QBCBlobObjectAccessResult
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of QBCBlobObjectAccessResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)blobObjectAccessWithBlobID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)blobObjectAccessWithBlobID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Upload file using BlobObjectAccess

/** 
 Upload file using BlobObjectAccess
 
 Type of Result - Result
 
 @param data File
 @param access An instance of QBCBlobObjectAccess
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)uploadFile:(NSData *)data blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)uploadFile:(NSData *)data blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Download file

/** 
 Download file
 
 Type of Result - QBCFileResult
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained. Upon finish of the request, result will be an instance of QBCFileResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)downloadFileWithUID:(NSString *)UID delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)downloadFileWithUID:(NSString *)UID delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Tasks


#pragma mark -
#pragma mark Upload File Task

/**
 Upload File task. Contains 3 quieries: Create Blob, upload file, declaring file uploaded 
 
 Type of Result - QBCFileUploadTaskResult
 
 @param data file to be uploaded
 @param fileName name of the file
 @param contentType type of the content in mime format
 @param isPublic blob's visibility
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCFileUploadTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)TUploadFile:(NSData*)data
                            fileName:(NSString*)fileName
                         contentType:(NSString*)contentType
                            isPublic:(BOOL)isPublic
                            delegate:(NSObject<QBActionStatusDelegate>*)delegate;

+ (NSObject<Cancelable>*)TUploadFile:(NSData*)data
                            fileName:(NSString*)fileName
                         contentType:(NSString*)contentType
                            isPublic:(BOOL)isPublic
                            delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;


#pragma mark -
#pragma mark Download File Task

/**
 Download File task. Contains 3 quieries: Get Blob with ID, download file
 
 Type of Result - QBCDownloadFileTaskResult
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCUploadFileTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)TDownloadFileWithBlobID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*)TDownloadFileWithBlobID:(NSUInteger)blobID delegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void *)context;

@end
