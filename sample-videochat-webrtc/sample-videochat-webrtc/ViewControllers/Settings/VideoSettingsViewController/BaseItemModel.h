//
//  BaseItemModel.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsItemDelegate;

@interface BaseItemModel : NSObject 

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id data;

- (Class)viewClass;

@end