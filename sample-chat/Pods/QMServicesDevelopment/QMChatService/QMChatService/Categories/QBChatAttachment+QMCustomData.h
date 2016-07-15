//
//  QBChatAttachment+QMCustomData.h
//  QMServices
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatAttachment (QMCustomData)

/**
 *  Attachment custom data context, based on dictionary.
 *
 *  @discussion Add or remove data, that you need to put into customData field of attachment.
 *  
 *  @note You should always call 'synchronize' method after context change.
 */
@property (strong, nonatomic, readonly, QB_NONNULL) NSMutableDictionary *context;

/**
 *  Synchronize context into attachment custom data field.
 *
 *  @discussion Call this method after every context update.
 *  
 *  @note This will convert NSDictionary into JSON and put into QBChatAttachment customData field.
 */
- (void)synchronize;

@end
