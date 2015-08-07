//
//  STKIntroService.h
//  StickerPipe
//
//  Created by Vadim Degterev on 27.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKIntroService : NSObject

+ (BOOL)needToShowIntro;
+ (void)setIntroWasShowed:(BOOL)showed;

@end
