//
// Created by Andrey Kozlov on 09/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBResponsePage : NSObject

@property (nonatomic) NSInteger skip;
@property (nonatomic) NSInteger limit;

+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit;
+ (QBResponsePage *)responsePageWithLimit:(NSInteger)limit skip:(NSInteger)skip;

+ (QBResponsePage *)responsePageForLastRecord;

@end