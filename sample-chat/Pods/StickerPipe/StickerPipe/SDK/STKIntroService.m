//
//  STKIntroService.m
//  StickerPipe
//
//  Created by Vadim Degterev on 27.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKIntroService.h"

static NSString* const kIntroShowedDefaultsKey = @"introDefaultsKey";

@implementation STKIntroService


+ (BOOL)needToShowIntro {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isIntroShowed = [defaults boolForKey:kIntroShowedDefaultsKey];
    return !isIntroShowed;
}

+ (void)setIntroWasShowed:(BOOL)showed {
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:showed forKey:kIntroShowedDefaultsKey];
}


@end
