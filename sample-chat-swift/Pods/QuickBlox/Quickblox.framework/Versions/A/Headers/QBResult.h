//
//  QBResult.h
//  Core
//

#import <Foundation/Foundation.h>

@class Request;
@class Answer;

/** QBResult class declaration */
/** Overview */
/** This class represents a QBResult instance. */

@interface QBResult : NSObject {
	Request *request;
	Answer *answer;
}

/** An array of instances of NSString */
@property (nonatomic,readonly) NSArray* errors;

/** YES if operation completed successfully. If equal to NO, see errors for more information */
@property (nonatomic,readonly) BOOL success;

/** HTTP status */
@property (nonatomic,readonly) NSUInteger status;

@property (nonatomic,retain) Request *request;
@property (nonatomic,retain) Answer *answer;

- (id)initWithRequest:(Request *)req answer:(Answer *)answ;
- (id)initWithAnswer:(Answer *)answ;

@end