#import "STKStatistic.h"

@interface STKStatistic ()

// Private interface goes here.

@end

@implementation STKStatistic

// Custom logic goes here.

- (NSDictionary *)dictionary {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.category) {
        [dictionary setObject:self.category forKey:STKStatisticAttributes.category];
    }
    if (self.time) {
        [dictionary setObject:self.time forKey:STKStatisticAttributes.time];
    }
    if (self.action) {
        [dictionary setObject:self.action forKey:STKStatisticAttributes.action];
    }
    if (self.label) {
        [dictionary setObject:self.label forKey:STKStatisticAttributes.label];
    }
    if (self.value) {
        [dictionary setObject:self.value forKey:STKStatisticAttributes.value];
    }
    
    
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
    
    return resultDictionary;
    
}

@end
