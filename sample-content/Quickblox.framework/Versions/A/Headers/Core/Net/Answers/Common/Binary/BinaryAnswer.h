//
//  BinaryAnswer.h
//  BaseService
//
//

#import <Foundation/Foundation.h>


@interface BinaryAnswer : RestAnswer {
	NSData* loadedData;
}

@property (nonatomic,readonly) NSData* loadedData;

@end
