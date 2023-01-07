//
//  NSError+Chat.h
//  sample-chat
//
//  Created by Injoit on 06.10.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (Chat)
@property (assign, nonatomic, readonly) BOOL isNetworkError;
@end

NS_ASSUME_NONNULL_END
