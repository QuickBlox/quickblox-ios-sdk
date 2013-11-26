//
//  Answer.h
//  BaseService
//
//
@class QBQuery;

@interface Answer : NSObject {
	NSMutableArray *errors;
}
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, assign) QBQuery* query;

-(Result*)allocResult;

@end