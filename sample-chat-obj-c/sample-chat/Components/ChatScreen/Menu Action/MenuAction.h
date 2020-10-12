//
//  MenuAction.h
//  samplechat
//
//  Created by Injoit on 08.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MenuActionHandler)(void);

@interface MenuAction : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) MenuActionHandler handler;

- (instancetype)initWithTitle:(NSString *)title handler:(MenuActionHandler _Nullable)handler;

@end

NS_ASSUME_NONNULL_END
