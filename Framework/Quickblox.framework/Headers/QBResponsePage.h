//
// Created by Andrey Kozlov on 09/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>


@interface QBResponsePage : NSObject

@property (nonatomic) NSInteger skip;
@property (nonatomic) NSInteger limit;
@property (nonatomic, readonly) NSUInteger totalEntries;

+ (QB_NONNULL QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QB_NONNULL QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;
+ (QB_NONNULL QBResponsePage *)responsePageForLastRecord;

+ (QB_NONNULL QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip totalEntries:(NSUInteger)totalEntries;

@end