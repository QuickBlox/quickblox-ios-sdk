//
//  QBMPushMessageBase.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBMPushMessageBase : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *payloadDict;

- (instancetype)initWithPayload:(NSDictionary<NSString *, NSString *> *)payload;
- (nullable NSString *)json;

@end

NS_ASSUME_NONNULL_END
