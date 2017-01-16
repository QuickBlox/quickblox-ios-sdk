//
//  QMChatResources.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 8/10/16.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import "QMChatResources.h"

static inline NSBundle *bundle() {
    
    static NSBundle *bundle = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path = [[NSBundle bundleForClass:[QMChatResources class]] pathForResource:@"QMChatViewController" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
        
        if (bundle == nil) {
            // if bundle with path is not existent that means that chat controller
            // was installed as a source from github, using main bundle instead
            bundle = [NSBundle mainBundle];
        }
    });
    
    return bundle;
}

@implementation QMChatResources

+ (NSBundle *)resourceBundle {
    
    return bundle();
}

+ (UIImage *)imageNamed:(NSString *)name {
    
    UIImage *image = nil;
    
    NSString *path = [bundle() pathForResource:name ofType:@"png"];
    if (path != nil) {
        
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    return image;
}

+ (UINib *)nibWithNibName:(NSString *)name {
    
    return [UINib nibWithNibName:name bundle:bundle()];
}

@end
