//
//  ProgressDispatcher.h
//  BaseService
//
//

#import <Foundation/Foundation.h>

@interface ProgressDispatcher : NSObject<ProgressDelegate> {
	NSObject<ProgressDelegate> *target;
	SEL action;
}
@property (nonatomic,retain) NSObject<ProgressDelegate> *target;
@property (nonatomic) SEL action;

- (id)initWithTarget:(NSObject *)target action:(SEL)action;
+ (ProgressDispatcher *)dispatcherForTarget:(NSObject *)target action:(SEL)action;

@end
