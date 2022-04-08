//
//  NSURL+Chat.h
//  sample-chat
//
//  Created by Injoit on 06.03.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Chat)
- (void)getThumbnailImageFromVideoUrlWithCompletion:(void(^)(UIImage *image))completion;
- (void)imageFromPDFfromURLWithCompletion:(void(^)(UIImage *image))completion;
@end

NS_ASSUME_NONNULL_END
