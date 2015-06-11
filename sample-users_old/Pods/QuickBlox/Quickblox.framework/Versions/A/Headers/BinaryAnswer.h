//
//  BinaryAnswer.h
//  BaseService
//
//

#import <Foundation/Foundation.h>
#import "XmlAnswer.h"

@interface BinaryAnswer : XmlAnswer {
	NSData *loadedData;
}

@property (nonatomic,readonly) NSData *loadedData;

@end
