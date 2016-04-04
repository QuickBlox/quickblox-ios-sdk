//
//  NSString+MD5.h
//
//  Created by Keith Smiley on 3/25/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

@import Foundation;


#ifdef NS_ASSUME_NONNULL_BEGIN
NS_ASSUME_NONNULL_BEGIN
#endif

@interface NSString (MD5)

- (NSString *)MD5Digest;

@end

#ifdef NS_ASSUME_NONNULL_END
NS_ASSUME_NONNULL_END
#endif
