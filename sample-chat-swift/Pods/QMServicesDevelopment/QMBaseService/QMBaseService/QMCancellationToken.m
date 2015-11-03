//
//  QMCancellationToken.m
//  QMBaseService
//
//  Created by Andrey Moskvin on 10/26/15.
//
//

#import "QMCancellationToken.h"

@interface QMCancellationToken ()

@property (nonatomic, assign) BOOL isCancelled;

@end

@implementation QMCancellationToken

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isCancelled = NO;
    }
    return self;
}

- (void)cancel
{
    self.isCancelled = YES;
}

@end
