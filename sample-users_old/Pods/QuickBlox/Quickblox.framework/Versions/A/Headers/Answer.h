//
//  Answer.h
//  BaseService
//
//

@class QBQuery;
@class Result;

@interface Answer : NSObject {
	NSMutableArray *errors;
}
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, assign) QBQuery* query;

-(Result*)allocResult;

@end