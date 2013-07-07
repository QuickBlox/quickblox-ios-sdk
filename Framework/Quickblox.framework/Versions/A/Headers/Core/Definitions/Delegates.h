/*
 *  Delegates.h
 *  
 *
 *
 */

/** Protocol of cancelable objects, mostly used with asynchronous operations */
@protocol Cancelable
/** Cancel current execution */
-(void)cancel;
@end


@class Result;

/** Protocol for asynchronous requests delegates */
@protocol QBActionStatusDelegate

@optional
/** Called when operation has completed */
-(void)completedWithResult:(Result*)result;

/** Called when operation has completed and context was set upon starting of the operation */
-(void)completedWithResult:(Result*)result context:(void*)contextInfo;

/** Called when operation progress has changed */
-(void)setProgress:(float)progress;

/** Called when upload operation progress has changed */
-(void)setUploadProgress:(float)progress;

@end


@protocol ProgressDelegate
-(void)setProgress:(float)progress;
@end


@protocol LoadProgressDelegate
-(void)setUploadProgress:(float)progress;
-(void)setDownloadProgress:(float)progress;
@optional
-(void)setProgress:(float)progress;
@end


@class RestResponse;
@protocol RestRequestDelegate<LoadProgressDelegate>
-(void)completedWithResponse:(RestResponse*)response;
@end


@protocol Perform
-(NSObject<Cancelable>*)performAsyncWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate;
-(NSObject<Cancelable>*)performAsyncWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void*)context;
@end