//
//  QMCancellationToken.h
//  QMBaseService
//
//  Created by Andrey Moskvin on 10/26/15.
//
//

#import <Foundation/Foundation.h>

@interface QMCancellationToken : NSObject

@property (nonatomic, assign, readonly) BOOL isCancelled;

- (void)cancel;

@end
