//
//  BinaryAnswer.h
//  BaseService
//
//

#import <Foundation/Foundation.h>


@interface BinaryAnswer : XmlAnswer {
	NSData *loadedData;
}

@property (nonatomic,readonly) NSData *loadedData;

@end
