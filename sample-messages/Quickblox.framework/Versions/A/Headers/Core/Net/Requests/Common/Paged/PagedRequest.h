//
//  PagedRequest.h
//  Core
//
//

#import <Foundation/Foundation.h>

@class PagedResult;

/** PagedRequest class declaration */
/** Overview */
/** This class represent an instance of request with pagination. */

@interface PagedRequest : Request {
@protected
	NSUInteger page;
	NSUInteger perPage;
}

/** Page number of the elements of the results that you want to get. By default: 1 */
@property (nonatomic) NSUInteger page;

/** The maximum number of results per page. Min: 1. Max: 100. By default: 10 */
@property (nonatomic) NSUInteger perPage;

@end
