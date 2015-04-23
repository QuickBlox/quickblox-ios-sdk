//
//  AsyncCanceler.h
//  BaseService
//
//

#import <Foundation/Foundation.h>
#import "QBCoreDelegates.h"

@interface AsyncCanceler : NSObject<Cancelable>

@property (nonatomic, weak) NSObject<Cancelable>* cancelable;
+(AsyncCanceler*)cancelerFor:(NSObject<Cancelable>*)cancelable;

@end
