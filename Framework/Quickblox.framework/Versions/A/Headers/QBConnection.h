//
// Created by Andrey Kozlov on 01/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBSettings.h"

@interface QBConnection : NSObject

/**
 Re-creates background NSURLSession. This method must be called in 'application:handleEventsForBackgroundURLSession:completionHandler:' to make NSURLSessionDelegate delegates called.
 */
+ (void)restoreBackgroundSession;

/**
 Must be set before request is fired. Sets a block to be executed when a download task has completed a download, as handled by the `NSURLSessionDownloadDelegate` method `URLSession:downloadTask:didFinishDownloadingToURL:`.
 
 @param block A block object to be executed when a download task has completed. The block returns the URL the download should be moved to, and takes three arguments: the session, the download task, and the temporary location of the downloaded file. If the file manager encounters an error while attempting to move the temporary file to the destination, an `AFURLSessionDownloadTaskDidFailToMoveFileNotification` will be posted, with the download task as its object, and the user info of the error.
 */
+ (void)setDownloadTaskDidFinishDownloadingBlock:(QB_NULLABLE NSURL * QB_NULLABLE_S (^)( NSURLSession * QB_NONNULL_S session, NSURLSessionDownloadTask * QB_NONNULL_S downloadTask, NSURL * QB_NONNULL_S location))block;

/**
 Sets a block to be executed once all messages enqueued for a session have been delivered, as handled by the `NSURLSessionDataDelegate` method `URLSessionDidFinishEventsForBackgroundURLSession:`.
 
 @param block A block object to be executed once all messages enqueued for a session have been delivered. The block has no return value and takes a single argument: the session.
 */
+ (void)setURLSessionDidFinishBackgroundEventsBlock:(QB_NULLABLE void (^)(NSURLSession * QB_NULLABLE_S session))block;

@end
