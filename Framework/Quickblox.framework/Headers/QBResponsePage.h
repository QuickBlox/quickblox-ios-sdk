//
// Created by QuickBlox team on 09/03/2014.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBResponsePage : NSObject

@property (nonatomic) NSInteger skip;
@property (nonatomic) NSInteger limit;
@property (nonatomic, readonly) NSUInteger totalEntries;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;
+ (QBResponsePage *)responsePageForLastRecord;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip totalEntries:(NSUInteger)totalEntries;

@end

NS_ASSUME_NONNULL_END
