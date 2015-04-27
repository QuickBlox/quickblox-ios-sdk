//
//  LocalStorageService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorageService : NSObject

@property (nonatomic, strong) QBUUser *currentUser;

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) NSDictionary *usersAsDictionary;

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, strong) NSMutableDictionary *messages;

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId;
- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId;
- (void)addMessage:(QBChatAbstractMessage *)message forDialogId:(NSString *)dialogId;

+ (instancetype)shared;

@end
