//
//  Request.h
//  Core
//
//

#import <Foundation/Foundation.h>

@interface Request : NSObject {
}
@property (nonatomic,readonly) NSDictionary* parameters;

/** Create new user
 @return New instance of Request
 */
+ (id)request;

@end
