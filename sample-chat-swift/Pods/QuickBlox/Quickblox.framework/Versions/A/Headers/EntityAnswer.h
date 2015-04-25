//
//  EntityAnswer.h
//  BaseService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlAnswer.h"

@class Entity;

@interface EntityAnswer : XmlAnswer {
	Entity* entity;
}
@property (nonatomic,retain) Entity* entity;

+ (NSString*)entityElementName;
+ (Class)entityClass;

@end