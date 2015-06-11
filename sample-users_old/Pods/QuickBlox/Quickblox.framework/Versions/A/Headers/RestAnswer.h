//
//  RestAnswer.h
//  Core
//
//

#import <Foundation/Foundation.h>
#import "QBCoreEnums.h"
#import "Answer.h"

@class QBRestResponse;

@interface RestAnswer : Answer {
	
@protected
	enum RestAnswerKind kind;
	QBRestResponse *response;
}
@property (nonatomic, readonly) enum RestAnswerKind kind;
@property (nonatomic, readonly) QBRestResponse *response;

- (id)initWithResponse:(QBRestResponse *) response;
- (void)load;

@end
