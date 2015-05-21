//
//  XMPPSASLAuthentication.h
//  iPhoneXMPP
//
//  Created by Eric Chamberlain on 10/1/11.
//  Copyright 2011 RingFree Mobility Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QBXMPPSASLAuthentication <NSObject>

- (NSString *)base64EncodedFullResponse;

@end
