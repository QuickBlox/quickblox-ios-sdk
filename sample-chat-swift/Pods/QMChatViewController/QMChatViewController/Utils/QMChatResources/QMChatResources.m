//
//  QMChatResources.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 8/10/16.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import "QMChatResources.h"

@implementation QMChatResources

+ (NSBundle *)resourceBundle {
    
    static NSBundle *_bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _bundle = [NSBundle bundleForClass:[QMChatResources class]];
        NSURL *url = [_bundle URLForResource:@"QMChatViewController" withExtension:@"bundle"];
        _bundle = [NSBundle bundleWithURL:url];
        
        if (_bundle == nil) {
            // if bundle with path is not existent that means that chat controller
            // was installed as a source from github, using main bundle instead
            _bundle = [NSBundle mainBundle];
        }
    });
    
    return _bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    
    UIImage *image = [UIImage imageNamed:name
                                inBundle:[self resourceBundle]
           compatibleWithTraitCollection:nil];
    
    return image;
}

+ (UINib *)nibWithNibName:(NSString *)name {
    
    return [UINib nibWithNibName:name bundle:[self resourceBundle]];
}

@end
