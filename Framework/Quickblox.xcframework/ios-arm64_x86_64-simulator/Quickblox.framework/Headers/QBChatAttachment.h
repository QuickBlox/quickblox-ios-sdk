//
//  QBChatAttachment.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBChatAttachment : NSObject <NSCoding, NSCopying>

/**
 Attachment name.
 */
@property (nonatomic, copy, nullable ) NSString *name;

/**
 Type of attachment.
 
 @discussion Can be any type. For example: audio, video, image, location, any other
 */
@property (nonatomic, copy, nullable) NSString *type;

/**
 Content URL.
 */
@property (nonatomic, copy, nullable) NSString *url;

/**
  ID of attached element.
 */
@property (nonatomic, copy, nullable) NSString *ID;


@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, NSString *> *customParameters;

//MARK: Keyed subscription for customParameters

- (nullable NSString *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable NSString *)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
