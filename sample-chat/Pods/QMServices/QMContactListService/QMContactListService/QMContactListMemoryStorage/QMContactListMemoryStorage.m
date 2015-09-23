//
//  QMContactListMemoryStorage.m
//  QMServices
//
//  Created by Andrey on 25.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMContactListMemoryStorage.h"

@interface QMContactListMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *contactList;

@end

@implementation QMContactListMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.contactList = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)updateWithContactList:(QBContactList *)contactList {
    
    [self.contactList removeAllObjects];
    
    [contactList.contacts enumerateObjectsUsingBlock:^(QBContactListItem *contactListItem, NSUInteger idx, BOOL *stop) {
        self.contactList[@(contactListItem.userID)] = contactListItem;
    }];
    
    [contactList.pendingApproval enumerateObjectsUsingBlock:^(QBContactListItem *contactListItem, NSUInteger idx, BOOL *stop) {
        self.contactList[@(contactListItem.userID)] = contactListItem;
    }];
}

- (void)updateWithContactListItems:(NSArray *)contactListItems {
    
    [self.contactList removeAllObjects];
    [contactListItems enumerateObjectsUsingBlock:^(QBContactListItem *contactListItem, NSUInteger idx, BOOL *stop) {
        self.contactList[@(contactListItem.userID)] = contactListItem;
    }];
}

- (NSArray *)userIDsFromContactList {
    
    return self.contactList.allKeys;
}

- (QBContactListItem *)contactListItemWithUserID:(NSUInteger)userID {
    
    return self.contactList[@(userID)];
}

#pragma mark - QMMemoryStorageProtocol

- (void)free {
    
    [self.contactList removeAllObjects];
}

@end
