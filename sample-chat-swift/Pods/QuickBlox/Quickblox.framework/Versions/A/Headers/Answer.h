//
//  Answer.h
//  BaseService
//
//

@class QBQuery;
@class QBResult;

@interface Answer : NSObject {
	NSMutableArray *errors;
}
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, assign) QBQuery* query;

-(QBResult *)allocResult;

@end