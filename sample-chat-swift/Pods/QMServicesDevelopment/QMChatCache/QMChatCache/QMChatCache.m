//
//  QMChatCache.m
//  QMServices
//
//  Created by Andrey on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatCache.h"
#import "QMCCModelIncludes.h"

@implementation QMChatCache

static QMChatCache *_chatCacheInstance = nil;

#pragma mark - Singleton

+ (QMChatCache *)instance {
    
    NSAssert(_chatCacheInstance, @"You must first perform @selector(setupDBWithStoreNamed:)");
    return _chatCacheInstance;
}

#pragma mark - Configure store

+ (void)setupDBWithStoreNamed:(NSString *)storeName {

    NSManagedObjectModel *model = [NSManagedObjectModel QM_newModelNamed:@"QMChatServiceModel.momd" inBundleNamed:@"QMChatCacheModel.bundle"];
    
    _chatCacheInstance = [[QMChatCache alloc] initWithStoreNamed:storeName model:model queueLabel:"com.qmunicate.QMChatCacheBackgroundQueue"];
}

+ (void)cleanDBWithStoreName:(NSString *)name {
    
    if (_chatCacheInstance) {
        _chatCacheInstance = nil;
    }
    
    [super cleanDBWithStoreName:name];
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.messagesLimitPerDialog = NSNotFound;
    }
    
    return self;
}

#pragma mark -
#pragma mark Dialogs
#pragma mark -

- (NSArray *)convertCDDialogsTOQBChatDialogs:(NSArray *)cdDialogs {
    
    NSMutableArray *qbChatDialogs = [NSMutableArray arrayWithCapacity:cdDialogs.count];
    
    for (CDDialog *dialog in cdDialogs) {
        
        QBChatDialog *qbUser = [dialog toQBChatDialog];
        [qbChatDialogs addObject:qbUser];
    }
    
    return qbChatDialogs;
}

#pragma mark Fetch Dialogs

- (void)dialogsSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending completion:(void(^)(NSArray *dialogs))completion {
    
    [self dialogsSortedBy:sortTerm ascending:ascending withPredicate:nil completion:completion];
}

- (void)dialogByID:(NSString *)dialogID completion:(void (^)(QBChatDialog *cachedDialog))completion {
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"(self.dialogID ==[cd] %@)",dialogID];
        
        CDDialog *cdChatDialog = [CDDialog QM_findFirstWithPredicate:fetchPredicate inContext:context];
        if (cdChatDialog != nil) {
            QBChatDialog *dialog = [[weakSelf convertCDDialogsTOQBChatDialogs:@[cdChatDialog]] firstObject];
            DO_AT_MAIN(completion(dialog));
        }
        else {
            DO_AT_MAIN(completion(nil));
        }
    }];
}

- (void)dialogsSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)predicate
             completion:(void(^)(NSArray *dialogs))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *cdChatDialogs = [CDDialog QM_findAllSortedBy:sortTerm ascending:ascending withPredicate:predicate inContext:context];
        NSArray *allDialogs = [weakSelf convertCDDialogsTOQBChatDialogs:cdChatDialogs];
        
        DO_AT_MAIN(completion(allDialogs));
    }];
}

#pragma mark Insert / Update / Delete

- (void)insertOrUpdateDialog:(QBChatDialog *)dialog completion:(dispatch_block_t)completion {
    
    [self insertOrUpdateDialogs:@[dialog] completion:completion];
}

- (void)insertOrUpdateDialogs:(NSArray *)dialogs completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSMutableArray *toInsert = [NSMutableArray array];
        NSMutableArray *toUpdate = [NSMutableArray array];
        
        //To Insert / Update
        for (QBChatDialog *dialog in dialogs) {
            
            NSParameterAssert(dialog.ID);
            
            CDDialog *cachedDialog = [CDDialog QM_findFirstWithPredicate:IS(@"dialogID", dialog.ID) inContext:context];
            
            if (cachedDialog) {
                
                QBChatDialog *tDialog = [cachedDialog toQBChatDialog];
                
                if (![dialog.updatedAt isEqual:tDialog.updatedAt] || dialog.unreadMessagesCount != tDialog.unreadMessagesCount) {
                    
                    [toUpdate addObject:dialog];
                }
            }
            else {
                
                [toInsert addObject:dialog];
            }
        }
        
        if (toUpdate.count > 0) {
            
            [weakSelf updateQBChatDialogs:toUpdate inContext:context];
        }
        
        if (toInsert.count > 0) {
            
            [weakSelf insertQBChatDialogs:toInsert inContext:context];
        }
        
        if (toInsert.count + toUpdate.count > 0) {
            [weakSelf save:completion];
        }
        
        NSLog(@"Dialogs to insert %lu", (unsigned long)toInsert.count);
        NSLog(@"Dialogs to update %lu", (unsigned long)toUpdate.count);
    }];
}

- (void)deleteDialogWithID:(NSString *)dialogID
                completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        [weakSelf deleteDialogWithID:dialogID inContext:context];
        
        [weakSelf save:completion];
        
    }];
}

- (void)deleteAllDialogs:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        [CDDialog QM_truncateAllInContext:context];
        
        [weakSelf save:completion];
    }];
}

#pragma mark Utils

- (void)insertQBChatDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context {
    
    for (QBChatDialog *qbChatDialog in qbChatDialogs) {
        
        CDDialog *dialogToInsert =
        [CDDialog QM_createEntityInContext:context];
        
        [dialogToInsert updateWithQBChatDialog:qbChatDialog];
    }
}

- (void)deleteDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context {
    
    for (QBChatDialog *qbChatDialog in qbChatDialogs) {
        
        [self deleteDialogWithID:qbChatDialog.ID inContext:context];
    }
}

- (void)updateQBChatDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context {
    
    for (QBChatDialog *qbChatDialog in qbChatDialogs) {
        
        CDDialog *dialogToUpdate =
        [CDDialog QM_findFirstWithPredicate:IS(@"dialogID", qbChatDialog.ID) inContext:context];
        [dialogToUpdate updateWithQBChatDialog:qbChatDialog];
    }
}

- (void)deleteDialogWithID:(NSString *)dialogID inContext:(NSManagedObjectContext *)context {
    
    CDDialog *dialogToDelete =
    [CDDialog QM_findFirstWithPredicate:IS(@"dialogID", dialogID) inContext:context];
    
    [dialogToDelete QM_deleteEntityInContext:context];
}

#pragma mark -
#pragma mark  Messages
#pragma mark -

- (NSArray *)convertCDMessagesTOQBChatHistoryMesages:(NSArray *)cdMessages {
    
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:cdMessages.count];
    
    for (CDMessage *message in cdMessages) {
        
        QBChatMessage *QBChatMessage = [message toQBChatMessage];
        [messages addObject:QBChatMessage];
    }
    
    return messages;
}

#pragma mark Fetch Messages

- (void)messagesWithDialogId:(NSString *)dialogId sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending completion:(void(^)(NSArray *array))completion {
    
    [self messagesWithPredicate:IS(@"dialogID", dialogId) sortedBy:sortTerm ascending:ascending completion:completion];
}

- (void)messagesWithPredicate:(NSPredicate *)predicate sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending completion:(void(^)(NSArray *messages))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *messages = [CDMessage QM_findAllSortedBy:sortTerm ascending:ascending withPredicate:predicate inContext:context];
        
        NSArray *result = [weakSelf convertCDMessagesTOQBChatHistoryMesages:messages];
        
        DO_AT_MAIN(completion(result));
    }];
}

#pragma mark Messages Limit

- (void)checkMessagesLimitForDialogWithID:(NSString *)dialogID withCompletion:(dispatch_block_t)completion {
    
    if (self.messagesLimitPerDialog == NSNotFound) {
        if (completion) completion();
        return;
    }
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSPredicate *messagePredicate = IS(@"dialogID", dialogID);
        
        if ([CDMessage QM_countOfEntitiesWithPredicate:messagePredicate inContext:context] > self.messagesLimitPerDialog) {
            
            NSFetchRequest *oldestMessageRequest = [NSFetchRequest fetchRequestWithEntityName:[CDMessage entityName]];
            
            oldestMessageRequest.fetchOffset = self.messagesLimitPerDialog;
            oldestMessageRequest.predicate = messagePredicate;
            oldestMessageRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateSend" ascending:NO]];
            
            NSArray *oldestMessagesForDialogID = [CDMessage QM_executeFetchRequest:oldestMessageRequest inContext:context];
            
            for (CDMessage *oldestMessage in oldestMessagesForDialogID) {
                [context deleteObject:oldestMessage];
            }
            
            [self save:completion];
            
        } else {
            
            if (completion) completion();
        }
        
    }];
}

#pragma mark Insert / Update / Delete

- (void)insertOrUpdateMessage:(QBChatMessage *)message withDialogId:(NSString *)dialogID read:(BOOL)isRead completion:(dispatch_block_t)completion {    
    message.dialogID = dialogID;
    message.read = isRead;
    
    [self insertOrUpdateMessage:message withDialogId:dialogID completion:completion];
}

- (void)insertOrUpdateMessage:(QBChatMessage *)message withDialogId:(NSString *)dialogID completion:(dispatch_block_t)completion {
 
    [self insertOrUpdateMessages:@[message] withDialogId:dialogID completion:completion];
}

- (void)insertOrUpdateMessages:(NSArray *)messages withDialogId:(NSString *)dialogID completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSMutableArray *toInsert = [NSMutableArray array];
        NSMutableArray *toUpdate = [NSMutableArray array];
        
        //To Insert / Update
        for (QBChatMessage *message in messages) {
            
            CDMessage *cdMessage = [CDMessage QM_findFirstWithPredicate:IS(@"messageID", message.ID) inContext:context];
            QBChatMessage *cachedMessage = [cdMessage toQBChatMessage];
            
            if (cdMessage) {
                
                if (![cachedMessage.deliveredIDs isEqualToArray:message.deliveredIDs] || ![cachedMessage.readIDs isEqualToArray:message.readIDs]) {
                    
                    [toUpdate addObject:message];
                }
                
            } else {
                
                [toInsert addObject:message];
            }
        }
        
        if (toUpdate.count > 0) {
            
            [weakSelf updateMessages:toUpdate inContext:context];
        }
        
        if (toInsert.count > 0) {
            
            [weakSelf insertMessages:toInsert inContext:context];
        }
        
        // Remove oldest messages
        
        if (toInsert.count + toUpdate.count > 0) {
            
            [weakSelf save:^{
               
                if ([toInsert count] > 0) {
                    [weakSelf checkMessagesLimitForDialogWithID:dialogID withCompletion:completion];
                } else {
                    if (completion) completion();
                }
                
                
            }];
        }
        
        NSLog(@"Messages to insert %lu", (unsigned long)toInsert.count);
        NSLog(@"Messages to update %lu", (unsigned long)toUpdate.count);
    }];
}

- (void)insertMessages:(NSArray *)messages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatMessage *message in messages) {
        
        CDMessage *messageToInsert = [CDMessage QM_createEntityInContext:context];
        [messageToInsert updateWithQBChatMessage:message];
    }
}

- (void)deleteMessages:(NSArray *)messages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatMessage *QBChatMessage in messages) {
        
        [self deleteMessage:QBChatMessage inContext:context];
    }
}

- (void)updateMessages:(NSArray *)messages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatMessage *message in messages) {
        
        CDMessage *messageToUpdate = [CDMessage QM_findFirstWithPredicate:IS(@"messageID", message.ID) inContext:context];
        [messageToUpdate updateWithQBChatMessage:message];
    }
}

- (void)deleteMessage:(QBChatMessage *)message inContext:(NSManagedObjectContext *)context {
    
    CDMessage *messageToDelete = [CDMessage QM_findFirstWithPredicate:IS(@"messageID", message.ID) inContext:context];
    [messageToDelete QM_deleteEntityInContext:context];
}

- (void)deleteMessagesWithDialogID:(NSString *)dialogID inContext:(NSManagedObjectContext *)context {
    
    [CDMessage QM_deleteAllMatchingPredicate:IS(@"dialogID", dialogID) inContext:context];
}

- (void)deleteMessage:(QBChatMessage *)message completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        [weakSelf deleteMessage:message inContext:context];
        
        [weakSelf save:^{
            
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)deleteMessages:(NSArray *)messages completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        //
        [weakSelf deleteMessages:messages inContext:context];
        
        [weakSelf save:^{
            //
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)deleteMessageWithDialogID:(NSString *)dialogID completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        [weakSelf deleteMessagesWithDialogID:dialogID inContext:context];
        
        [weakSelf save:^{
            
            if (completion) {
                completion();
            }
        }];
    }];
    
}

- (void)deleteAllMessages:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        [CDMessage QM_truncateAllInContext:context];
        
        [weakSelf save:^{
            
            if (completion) {
                completion();
            }
        }];
    }];
}

@end