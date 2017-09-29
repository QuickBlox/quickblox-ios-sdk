//
//  QBHTTPClient.h
//  Pods
//
//  Created by Quickblox team on 16/06/2017.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QBRequest;

typedef void(^qb_task_block)(NSURLSessionDataTask *task);
typedef void(^qb_task_data_block)(NSURLSessionDataTask *task, NSData *responseObject);
typedef void(^qb_task_error_block)(NSURLSessionDataTask * _Nullable task, NSError *error);
typedef void(^qb_task_progress_block)(NSProgress *downloadProgress);

@interface QBHTTPClient : NSObject

@property (readonly, nonatomic) NSURLSession *session;

/**
 The dispatch queue for `completionBlock`. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, nullable) dispatch_queue_t completionQueue;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Initializes an `QBHTTPClient` object with the specified base URL.
 
 @param url The base URL for the HTTP client.
 
 @return The newly-initialized HTTP client
 */
- (instancetype)initWithBaseURL:(nullable NSURL *)url;

/**
 Initializes an `QBHTTPClient` object with the specified base URL.
 
 This is the designated initializer.
 
 @param url The base URL for the HTTP client.
 @param configuration The configuration used to create the managed session.
 
 @return The newly-initialized HTTP client
 */
- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 Creates and runs an `QBRequest` with a `GET` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param downloadProgress A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (QBRequest *)GET:(NSString *)URLString
        parameters:(nullable id)parameters
          progress:(nullable qb_task_progress_block)downloadProgress
           success:(nullable qb_task_data_block)success
           failure:(nullable qb_task_error_block)failure;

/**
 Creates and runs an `QBRequest` with a `HEAD` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes a single arguments: the data task.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (QBRequest *)HEAD:(NSString *)URLString
         parameters:(nullable id)parameters
            success:(nullable qb_task_block)success
            failure:(nullable qb_task_error_block)failure;

/**
 Creates and runs an `QBRequest` with a `POST` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param uploadProgress A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (QBRequest *)POST:(NSString *)URLString
         parameters:(nullable id)parameters
           progress:(nullable qb_task_progress_block)uploadProgress
            success:(nullable qb_task_data_block)success
            failure:(nullable qb_task_error_block)failure;

/**
 Creates and runs an `QBRequest` with a `PUT` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (QBRequest *)PUT:(NSString *)URLString
        parameters:(nullable id)parameters
           success:(nullable qb_task_data_block)success
           failure:(nullable qb_task_error_block)failure;

/**
 Creates and runs an `QBRequest` with a `PATCH` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (QBRequest *)PATCH:(NSString *)URLString
          parameters:(nullable id)parameters
             success:(nullable qb_task_data_block)success
             failure:(nullable qb_task_error_block)failure;

/**
 Creates and runs an `QBRequest` with a `DELETE` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (QBRequest *)DELETE:(NSString *)URLString
           parameters:(nullable id)parameters
              success:(nullable qb_task_data_block)success
              failure:(nullable qb_task_error_block)failure;
@end

NS_ASSUME_NONNULL_END
