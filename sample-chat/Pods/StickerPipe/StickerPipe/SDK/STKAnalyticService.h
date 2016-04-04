//
//  STKAnalyticService.h
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


//Categories
extern NSString *const STKAnalyticMessageCategory;
extern NSString *const STKAnalyticStickerCategory;
extern NSString *const STKAnalyticPackCategory;
extern NSString *const STKAnalyticDevCategory;

//Actions
extern NSString *const STKAnalyticActionCheck;
extern NSString *const STKAnalyticActionInstall;
extern NSString *const STKAnalyticActionError;
extern NSString *const STKAnalyticActionSend;



//Labels
extern NSString *const STKStickersCountLabel;
extern NSString *const STKEventsCountLabel;
extern NSString *const STKMessageTextLabel;
extern NSString *const STKMessageStickerLabel;



@interface STKAnalyticService : NSObject

+ (instancetype) sharedService;

- (void)sendEventWithCategory:(NSString*)category
                       action:(NSString*)action
                        label:(NSString*)label
                        value:(NSNumber*)value;

@end
