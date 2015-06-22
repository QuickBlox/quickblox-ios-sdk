//
//  AsyncCanceler.h
//  BaseService
//
//

#import <Foundation/Foundation.h>
#import "QBCoreDelegates.h"

@interface AsyncCanceler : NSObject<Cancelable> {
	NSObject<Cancelable>* cancelable;
}
@property (nonatomic, unsafe_unretained) NSObject<Cancelable>* cancelable;

+(AsyncCanceler*)cancelerFor:(NSObject<Cancelable>*)cancelable;

@end
