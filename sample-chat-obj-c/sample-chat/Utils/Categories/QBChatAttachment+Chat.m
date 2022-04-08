//
//  QBChatAttachment+Chat.m
//  sample-chat
//
//  Created by Injoit on 18.03.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "QBChatAttachment+Chat.h"
#import "ImageCache.h"

@implementation QBChatAttachment (Chat)

- (NSURL *)cachedURL {
    NSString *appendingPathComponent = [NSString stringWithFormat:@"%@_%@", self.ID, self.name];
    NSString *path = [NSString stringWithFormat:@"%@/%@", ImageCache.instance.cachesDirectory, appendingPathComponent];
    NSURL *cachedURL = [NSURL fileURLWithPath:path];
    return cachedURL;
}

@end
