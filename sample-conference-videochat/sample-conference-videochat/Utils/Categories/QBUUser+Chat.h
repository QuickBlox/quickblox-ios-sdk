//
//  QBUUser+Chat.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBUUser (Chat)

@property (nonatomic, strong, readonly) NSString *name;

@end

NS_ASSUME_NONNULL_END
