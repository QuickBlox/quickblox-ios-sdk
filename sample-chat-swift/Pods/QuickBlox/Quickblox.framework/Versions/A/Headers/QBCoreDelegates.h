/*
 *  Delegates.h
 *  
 *
 *
 */


@class QBResult;
@class QBRestResponse;


/** Protocol of cancelable objects, mostly used with asynchronous operations */
@protocol Cancelable
/** Cancel current execution */
-(void)cancel;
@end

/** Protocol for asynchronous requests delegates */
@protocol QBActionStatusDelegate

@optional
/** Called when operation has completed */
-(void)completedWithResult:(QBResult *)result;

/** Called when operation has completed and context was set upon starting of the operation */
-(void)completedWithResult:(QBResult *)result context:(void*)contextInfo;

/** Called when operation progress has changed */
-(void)setProgress:(float)progress;

@end


@protocol RestRequestDelegate
-(void)completedWithResponse:(QBRestResponse*)response;
@optional
-(void)setProgress:(float)progress;
@end


@protocol Perform
-(NSObject<Cancelable>*)performAsyncWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate;
-(NSObject<Cancelable>*)performAsyncWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate context:(void*)context;
@end