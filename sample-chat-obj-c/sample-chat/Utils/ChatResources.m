//
//  ChatResources.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatResources.h"

@implementation ChatResources

+ (NSBundle *)resourceBundle {
    return [NSBundle mainBundle];
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
