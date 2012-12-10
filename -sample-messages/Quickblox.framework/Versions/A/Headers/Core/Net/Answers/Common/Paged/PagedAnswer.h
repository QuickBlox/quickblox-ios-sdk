//
//  PagedAnswer.h
//  Core
//
//

#import <Foundation/Foundation.h>


@interface PagedAnswer : XmlAnswer {
    NSUInteger currentPage;
    NSUInteger perPage;
    NSUInteger totalEntries;
}
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger perPage;
@property (nonatomic) NSUInteger totalEntries;

@end
