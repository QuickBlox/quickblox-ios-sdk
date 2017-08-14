#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QMAuthService.h"
#import "QMBaseService.h"
#import "QMMemoryStorageProtocol.h"
#import "QMServiceManagerProtocol.h"
#import "CDAttachment.h"
#import "CDDialog.h"
#import "CDMessage.h"
#import "_CDAttachment.h"
#import "_CDDialog.h"
#import "_CDMessage.h"
#import "QMCCModelIncludes.h"
#import "QMChatCache.h"
#import "QBChatAttachment+QMCustomData.h"
#import "QBChatMessage+QMCustomParameters.h"
#import "QMChatAttachmentService.h"
#import "QMChatConstants.h"
#import "QMChatService.h"
#import "QMChatTypes.h"
#import "QMDialogsMemoryStorage.h"
#import "QMMessagesMemoryStorage.h"
#import "CDContactListItem.h"
#import "_CDContactListItem.h"
#import "QMCLModelIncludes.h"
#import "QMContactListCache.h"
#import "QMContactListMemoryStorage.h"
#import "QMContactListService.h"
#import "NSManagedObject+QMCDAggregation.h"
#import "NSManagedObject+QMCDFinders.h"
#import "NSManagedObject+QMCDRecord.h"
#import "NSManagedObject+QMCDRequests.h"
#import "NSManagedObjectContext+QMCDObserving.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSManagedObjectContext+QMCDSaves.h"
#import "NSManagedObjectModel+QMCDRecord.h"
#import "NSPersistentStore+QMCDRecord.h"
#import "NSPersistentStore+QMCDRecordPrivate.h"
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "NSArray+QMCDRecord.h"
#import "NSDictionary+QMCDRecordAdditions.h"
#import "NSError+QMCDRecordErrorHandling.h"
#import "QMCDMigrationManager.h"
#import "QMCDRecord.h"
#import "QMCDRecord+Options.h"
#import "QMCDRecord+VersionInformation.h"
#import "QMCDRecordInternal.h"
#import "QMCDRecordLogging.h"
#import "QMCDRecordStack.h"
#import "QMDBStorage.h"
#import "QMDeferredAction.h"
#import "QMDeferredQueueManager.h"
#import "QMDeferredQueueMemoryStorage.h"
#import "QMServicesManager.h"
#import "QMServices.h"
#import "QMSLog.h"
#import "CDUser.h"
#import "_CDUser.h"
#import "QMUsersModelIncludes.h"
#import "QMUsersCache.h"
#import "QBUUser+CustomData.h"
#import "QMUsersMemoryStorage.h"
#import "QMUsersService.h"

FOUNDATION_EXPORT double QMServicesDevelopmentVersionNumber;
FOUNDATION_EXPORT const unsigned char QMServicesDevelopmentVersionString[];

