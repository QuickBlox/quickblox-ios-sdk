#import <Foundation/Foundation.h>
#import "QBXMPPElement.h"


@interface QBXMPPElement (XEP0203)

- (BOOL)wasDelayed;
- (NSDate *)delayedDeliveryDate;

@end
