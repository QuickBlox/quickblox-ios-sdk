//
//  BaseItemModel.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id data;

- (instancetype)initWithTitle:(NSString *)title data:(id)data;
- (instancetype)initWithTitle:(NSString *)title;
- (Class)viewClass;

@end