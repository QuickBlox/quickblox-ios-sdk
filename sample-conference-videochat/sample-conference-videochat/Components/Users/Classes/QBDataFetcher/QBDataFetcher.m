//
//  QBDataFetcher.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBDataFetcher.h"
#import "QBCore.h"
#import <Quickblox/Quickblox.h>

static const NSUInteger kQBPageLimit = 50;
static const NSUInteger kQBPageSize = 50;

@implementation QBDataFetcher

+ (void)fetchDialogs:(void(^)(NSArray *dialogs))completion {
    
    NSDictionary *extendedRequest = @{
                                      @"type[in]" : @2,
                                      };
    
    __block void(^t_request)(QBResponsePage *responsePage, NSMutableArray *allDialogs);
    void(^request)(QBResponsePage *, NSMutableArray *) = ^(QBResponsePage *responsePage, NSMutableArray *allDialogs) {
        
        [QBRequest dialogsForPage:responsePage
                  extendedRequest:extendedRequest
                     successBlock:^(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsersIDs, QBResponsePage *page)
         {
             [allDialogs addObjectsFromArray:dialogs];
             
             BOOL cancel = NO;
             page.skip += dialogs.count;
             
             if (page.totalEntries <= page.skip) {
                 
                 cancel = YES;
             }
             
             if (!cancel) {
                 
                 t_request(page, allDialogs);
             }
             else {
                 
                 if (completion != nil) {
                     completion([allDialogs copy]);
                 }
                 
                 t_request = nil;
             }
             
         } errorBlock:^(QBResponse *response) {
             
             if (completion != nil) {
                 completion([allDialogs copy]);
             }
             
             t_request = nil;
         }];
    };
    
    t_request = [request copy];
    NSMutableArray *allDialogs = [[NSMutableArray alloc] init];
    request([QBResponsePage responsePageWithLimit:kQBPageLimit], allDialogs);
}

+ (void)fetchUsers:(void(^)(NSArray *users))completion {
    
    __weak __typeof(self)weakSelf = self;
    __block void(^t_request)(QBGeneralResponsePage *page, NSMutableArray *allUsers);
    void(^request)(QBGeneralResponsePage *, NSMutableArray *) = ^(QBGeneralResponsePage *page, NSMutableArray *allUsers) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        [QBRequest usersWithTags:Core.currentUser.tags
                            page:page
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBUUser *> *users)
         {
             page.currentPage++;
             [allUsers addObjectsFromArray:users];
             
             BOOL cancel = NO;
             if (page.currentPage * page.perPage >= page.totalEntries) {
                 cancel = YES;
             }
             
             if (!cancel) {
                 t_request(page, allUsers);
             }
             else {
                 
                 if (completion != nil) {
                     completion([strongSelf excludeCurrentUserFromUsersArray:[allUsers copy]]);
                 }
                 
                 t_request = nil;
             }
             
         } errorBlock:^(QBResponse *response) {
             
             if (completion != nil) {
                 completion([strongSelf excludeCurrentUserFromUsersArray:[allUsers copy]]);
             }
             
             t_request = nil;
         }];
    };
    
    t_request = [request copy];
    NSMutableArray *allUsers = [[NSMutableArray alloc] init];
    request([QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:kQBPageSize], allUsers);
}

+ (NSArray *)excludeCurrentUserFromUsersArray:(NSArray *)users {
    
    QBUUser *currentUser = Core.currentUser;
    if ([users containsObject:currentUser]) {
        
        NSMutableArray *mutableArray = [users mutableCopy];
        [mutableArray removeObject:currentUser];
        return [mutableArray copy];
    }
    return users;
}

@end
