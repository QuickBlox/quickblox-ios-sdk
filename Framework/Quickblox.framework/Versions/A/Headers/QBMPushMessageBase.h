//
//  QBMPushMessageBase.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>


@interface QBMPushMessageBase : NSObject <NSCoding, NSCopying>{
	NSMutableDictionary *payloadDict;
}
@property (nonatomic,retain, QB_NULLABLE_PROPERTY) NSMutableDictionary QB_GENERIC(NSString *, id) *payloadDict;

- (QB_NONNULL instancetype)initWithPayload:(QB_NONNULL NSDictionary QB_GENERIC(NSString *, NSString *) *)payload;
- (QB_NULLABLE NSString *)json;

@end
