//
//  PagedResult.h
//  Core
//
//

#import <Foundation/Foundation.h>


@interface PagedResult : Result {

}
@property(nonatomic, readonly) NSUInteger currentPage;
@property(nonatomic, readonly) NSUInteger totalPages;
@property(nonatomic, readonly) NSUInteger perPage;
@property(nonatomic, readonly) NSUInteger totalEntries;

/*
-(PagedResult *)askForPage:(NSUInteger)page;
-(PagedResult *)nextPage;
-(PagedResult *)prevPage;
*/

@end