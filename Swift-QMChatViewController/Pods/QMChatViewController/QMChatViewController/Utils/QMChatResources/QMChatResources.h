//
//  QMChatResources.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 8/10/16.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMChatResources : NSObject

+ (NSBundle *)resourceBundle;

+ (UIImage *)imageNamed:(NSString *)name;
+ (UINib *)nibWithNibName:(NSString *)name;

@end
