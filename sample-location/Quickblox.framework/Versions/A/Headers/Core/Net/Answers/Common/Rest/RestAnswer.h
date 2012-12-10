//
//  RestAnswer.h
//  Core
//
//

#import <Foundation/Foundation.h>


@interface RestAnswer : Answer {
	
@protected
	enum RestAnswerKind kind;
	RestResponse* response;
}
@property(nonatomic,readonly) enum RestAnswerKind kind;
@property(nonatomic,readonly) enum RestAnswerKind expectedKind;
@property(nonatomic,readonly) RestResponse* response;

-(id)initWithResponse:(RestResponse*) tresponse;
-(void)load;
-(void)handleStatus;
-(void)handleResponseError:(NSError*)error;

@end
