//
//  STKStickersEntityService.h
//  StickerPipe
//
//  Created by Vadim Degterev on 27.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKStickersEntityService : NSObject

- (void)getStickerPacksWithType:(NSString*)type
                 completion:(void(^)(NSArray *stickerPacks))completion
                    failure:(void(^)(NSError *error))failure;

- (void) incrementStickerUsedCountWithID:(NSNumber*)stickerID;

@end
