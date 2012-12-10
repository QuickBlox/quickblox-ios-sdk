//
//  PagedQuery.h
//  Core
//
//

#import <Foundation/Foundation.h>


@interface PagedQuery : Query {
	NSUInteger page;
	NSUInteger perPage;
}

- (id)init;

@property (nonatomic) NSUInteger page;
@property (nonatomic) NSUInteger perPage;

@end
