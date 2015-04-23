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