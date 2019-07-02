//
//  BaseItemModel.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsItemDelegate;

@interface BaseItemModel : NSObject 

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id data;

- (Class)viewClass;

@end
