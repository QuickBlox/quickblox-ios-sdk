//
//  Answer.h
//  BaseService
//
//
@class Query;

@interface Answer : NSObject {
	NSMutableArray *errors;
}
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, assign) Query* query;

-(Result*)allocResult;

@end