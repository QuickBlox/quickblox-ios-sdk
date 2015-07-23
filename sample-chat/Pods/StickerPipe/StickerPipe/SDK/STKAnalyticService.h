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

//Actions
extern NSString *const STKAnalyticActionCheck;
extern NSString *const STKAnalyticActionInstall;


//Labels
extern NSString *const STKStickersCountLabel;
extern NSString *const STKEventsCountLabel;


@interface STKAnalyticService : NSObject

+ (instancetype) sharedService;

- (void)sendEventWithCategory:(NSString*)category
                       action:(NSString*)action
                        label:(NSString*)label
                        value:(NSNumber*)value;

@end
