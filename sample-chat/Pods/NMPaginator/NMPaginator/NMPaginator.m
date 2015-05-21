//
//  NMPaginator.m
//
//  Created by Nicolas Mondollot on 07/04/12.
//

#import "NMPaginator.h"

@interface NMPaginator() {
}

// protected properties
@property (assign, readwrite) NSInteger pageSize; 
@property (assign, readwrite) NSInteger page; 
@property (assign, readwrite) NSInteger total;
@property (nonatomic, strong, readwrite) NSMutableArray *results;
@property (assign, readwrite) RequestStatus requestStatus;

@end

@implementation NMPaginator
@synthesize delegate;
@synthesize page=_page, total=_total, results=_results, requestStatus=_requestStatus, pageSize=_pageSize;

- (id)initWithPageSize:(NSInteger)pageSize delegate:(id<NMPaginatorDelegate>)paginatorDelegate
{
    if(self = [super init])
    {
        [self setDefaultValues];
        self.pageSize = pageSize;
        self.delegate = paginatorDelegate;
    }
    
    return self;
}

- (void)setDefaultValues
{
    self.total = 0;
    self.page = 0;
    self.results = [NSMutableArray array];
    self.requestStatus = RequestStatusNone;
}

- (void)reset
{
    [self setDefaultValues];
    
    // send message to delegate
    if([self.delegate respondsToSelector:@selector(paginatorDidReset:)])
        [self.delegate paginatorDidReset:self];
}

- (BOOL)reachedLastPage
{
    if(self.requestStatus == RequestStatusNone) return NO; // if we haven't made a request, we can't know for sure
    
    NSInteger totalPages = ceil((float)self.total/(float)self.pageSize); // total number of pages
    return self.page >= totalPages;
}

# pragma - fetch results

- (void)fetchFirstPage
{     
    // reset paginator
    [self reset];
    
    [self fetchNextPage];
}

- (void)fetchNextPage
{    
    // don't do anything if there's already a request in progress
    if(self.requestStatus == RequestStatusInProgress) 
        return;
    
    if(![self reachedLastPage]) {
        self.requestStatus = RequestStatusInProgress;
        [self fetchResultsWithPage:self.page+1 pageSize:self.pageSize];
    }
}

#pragma mark - Sublclass methods

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // override this in subclass
}

#pragma mark received results

// call these from subclass when you receive the results

- (void)receivedResults:(NSArray *)results total:(NSInteger)total 
{
    [self.results addObjectsFromArray:results];
    self.page++;
    self.total = total;
    self.requestStatus = RequestStatusDone;
    
    [self.delegate paginator:self didReceiveResults:results];
}

- (void)failed
{
    self.requestStatus = RequestStatusDone;
    
    if([self.delegate respondsToSelector:@selector(paginatorDidFailToRespond:)])
        [self.delegate paginatorDidFailToRespond:self];
}

@end
