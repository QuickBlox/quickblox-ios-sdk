//
//  QMChatSection.m
//  Pods
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//
//

#import "QMChatSection.h"
#import <Quickblox/Quickblox.h>

@implementation QMChatSection

#pragma mark - Class methods

- (instancetype)init {
    if (self = [super init]) {
        self.messages = [NSMutableArray array];
    }
    
    return self;
}

+ (QMChatSection *)chatSection {
    return [[self alloc] init];
}

#pragma mark - Instance methods

- (NSString *)name {
    QBChatMessage *firstMessage = [self.messages firstObject];
    return [self formattedStringFromDate:firstMessage.dateSent];
}

- (NSDate *)firstMessageDate {
    QBChatMessage *firstMessage = [self.messages firstObject];
    return firstMessage.dateSent;
}

- (NSDate *)lastMessageDate {
    QBChatMessage *lastMessage = [self.messages lastObject];
    return lastMessage.dateSent;
}

#pragma mark - Helpers

- (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSString *formattedString = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *sectionDate = [dateFormatter stringFromDate:date];
    
    if (components.day == currentComponents.day && components.month == currentComponents.month && components.year == currentComponents.year) {
        formattedString = [NSString stringWithFormat:@"Today %@", sectionDate];
    } else if (components.day == currentComponents.day-1 && components.month == currentComponents.month && components.year == currentComponents.year) {
        formattedString = [NSString stringWithFormat:@"Yesterday %@", sectionDate];
    } else if (components.year == components.year) {
        formattedString = [NSString stringWithFormat:@"%@ %ld %@", [self monthFromNumber:components.month], (long)components.day, sectionDate];
    } else {
        formattedString = [NSString stringWithFormat:@"%@ %ld %ld %@", [self monthFromNumber:components.month], (long)components.day, (long)components.year, sectionDate];
    }
    return formattedString;
}

- (NSString *)monthFromNumber:(NSInteger)number
{
    NSDictionary *dict = @{@1: @"January",
                           @2: @"February",
                           @3: @"March",
                           @4: @"April",
                           @5: @"May",
                           @6: @"June",
                           @7: @"July",
                           @8: @"August",
                           @9: @"September",
                           @10: @"October",
                           @11: @"November",
                           @12: @"December"};
    return dict[@(number)];
}

@end
