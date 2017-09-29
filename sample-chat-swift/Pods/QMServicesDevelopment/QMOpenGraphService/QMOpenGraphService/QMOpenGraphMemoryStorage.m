//
//  QMOpenGraphMemoryStorage.m
//  QMOpenGraphService
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMOpenGraphMemoryStorage.h"
#import "QMOpenGraphItem.h"

@interface QMOpenGraphMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary<NSString *, QMOpenGraphItem *> *memoryStorage;

@end

@implementation QMOpenGraphMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _memoryStorage = [NSMutableDictionary dictionary];
    }
    return self;
}

- (QMOpenGraphItem *)objectForKeyedSubscript:(NSString *)key {
    return _memoryStorage[key];
}

- (void)setObject:(QMOpenGraphItem *)obj forKeyedSubscript:(NSString *)key {
    _memoryStorage[key] = obj;
}

- (QMOpenGraphItem *)openGraphItemWithBaseURL:(NSString *)baseUrl {
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"self.baseUrl == [c] %@", baseUrl];
    QMOpenGraphItem *item = [_memoryStorage.allValues filteredArrayUsingPredicate:predicate].firstObject;
    return item;
}

- (void)free {
    [_memoryStorage removeAllObjects];
}

@end
