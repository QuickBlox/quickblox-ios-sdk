//
//  CollectionViewFlowLayoutInvalidationContext.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CollectionViewFlowLayoutInvalidationContext.h"

@implementation CollectionViewFlowLayoutInvalidationContext
#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _invalidateFlowLayoutMessagesCache = NO;
    }
    return self;
}

+ (instancetype)context {
    return [[CollectionViewFlowLayoutInvalidationContext alloc] init];
}

#pragma mark - NSObject

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: invalidateFlowLayoutDelegateMetrics=%@, invalidateFlowLayoutAttributes=%@, invalidateDataSourceCounts=%@, invalidateFlowLayoutMessagesCache=%@>",
            [self class],
            @(self.invalidateFlowLayoutDelegateMetrics),
            @(self.invalidateFlowLayoutAttributes),
            @(self.invalidateDataSourceCounts),
            @(self.invalidateFlowLayoutMessagesCache)];
}

@end
