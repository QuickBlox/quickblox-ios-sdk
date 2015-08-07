#import "STKSticker.h"
#import "NSManagedObject+STKAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "STKStickerObject.h"

@interface STKSticker ()

// Private interface goes here.

@end

@implementation STKSticker

// Custom logic goes here.

//+ (NSArray *)stk_getRecentStickers {
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > 0", STKStickerAttributes.usedCount];
//    
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedCount
//                                                                     ascending:YES];
//    
//    NSArray *stickers = [self stk_findWithPredicate:predicate
//                                    sortDescriptors:@[sortDescriptor]
//                                         fetchLimit:12
//                                            context:[NSManagedObjectContext stk_defaultContext]];
//    return stickers;
//    
//}

//+ (STKSticker*)modelForObject:(STKStickerObject *)object {
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
//    request.predicate = [NSPredicate predicateWithFormat:@"stickerID == %@", object.stickerID];
//    request.fetchLimit = 1;
//    NSManagedObjectContext *context = [NSManagedObjectContext stk_backgroundContext];
//    
//    STKSticker *sticker = [context executeFetchRequest:request error:nil].firstObject;
//    
//    return sticker;
//    
//}


@end
