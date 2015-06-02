//
// Created by Andrey Kozlov on 09/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBResponsePage : NSObject

@property (nonatomic) NSInteger skip;
@property (nonatomic) NSInteger limit;
<<<<<<< HEAD
@property (nonatomic, readonly) NSUInteger totalEntries;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;
=======
@property (nonatomic) NSUInteger totalEntries;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip totalEntries:(NSUInteger)totalEntries;

>>>>>>> efdcc33fcc33fb4b9ca520bd016b3f15c8c2c907
+ (QBResponsePage *)responsePageForLastRecord;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip totalEntries:(NSUInteger)totalEntries;

@end