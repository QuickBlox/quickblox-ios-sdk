//
//  PagedQuery.h
//  Core
//
//

#import <Foundation/Foundation.h>
#import "QBQuery.h"


@interface PagedQuery : QBQuery {
	NSUInteger page;
	NSUInteger perPage;
}

- (id)init;

@property (nonatomic) NSUInteger page;
@property (nonatomic) NSUInteger perPage;

@end
