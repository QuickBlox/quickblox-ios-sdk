//
//  QBMPushMessageBase.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBMPushMessageBase : NSObject <NSCoding, NSCopying>{
	NSMutableDictionary *payloadDict;
}
@property (nonatomic,retain) NSMutableDictionary *payloadDict;

- (id)initWithPayload:(NSDictionary *)payload;
- (NSString *)json;
- (NSInteger)charsLeft;

@end
