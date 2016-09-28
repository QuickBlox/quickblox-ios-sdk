//
//  QBMPushMessageBase.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBMPushMessageBase : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, nullable) NSMutableDictionary QB_GENERIC(NSString *, id) *payloadDict;

- (instancetype)initWithPayload:(NSDictionary QB_GENERIC(NSString *, NSString *) *)payload;
- (nullable NSString *)json;

@end

NS_ASSUME_NONNULL_END
