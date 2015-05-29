//
// Created by Andrey Kozlov on 09/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBResponsePage : NSObject

@property (nonatomic) NSInteger skip;
@property (nonatomic) NSInteger limit;
<<<<<<< HEAD
@property (nonatomic) NSUInteger totalEntries;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip totalEntries:(NSUInteger)totalEntries;

=======
@property (nonatomic, readonly) NSUInteger totalEntries;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;
>>>>>>> 107331826949ebc17c9f9eba2c157e72a89fdb66
+ (QBResponsePage *)responsePageForLastRecord;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip totalEntries:(NSUInteger)totalEntries;

@end