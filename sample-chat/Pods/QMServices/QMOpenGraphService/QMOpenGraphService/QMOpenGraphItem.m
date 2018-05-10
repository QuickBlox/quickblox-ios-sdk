//
//  QMOpenGraphItem.m
//  QMOpenGraphService
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMOpenGraphItem.h"

@implementation QMOpenGraphItem
//MARK: - NSObject
- (NSString *)description {
    
    NSMutableString *desc = [NSMutableString stringWithString:[super description]];
    [desc appendFormat:@
     "\r   ID:%@"
     "\r   url: %@"
     "\r   title: %@"
     "\r   description: %@"
     "\r   fiveiconUrl: %@"
     "\r   imageURL: %@"
     "\r   width: %tu"
     "\r   height: %tu",
     _ID,
     _baseUrl,
     _siteTitle,
     _siteDescription,
     _faviconUrl,
     _imageURL,
     _imageWidth,
     _imageHeight];
    
    return desc;
}

//MARK: - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        
        _ID = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(ID))];
        _baseUrl = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(baseUrl))];
        _faviconUrl = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(faviconUrl))];
        _siteTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(siteTitle))];
        _siteDescription = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(siteDescription))];
        _imageURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageURL))];
        _imageWidth =  [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(imageWidth))];
        _imageHeight =  [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(imageHeight))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:_ID forKey:NSStringFromSelector(@selector(ID))];
    [aCoder encodeObject:_baseUrl forKey:NSStringFromSelector(@selector(baseUrl))];
    [aCoder encodeObject:_siteTitle forKey:NSStringFromSelector(@selector(siteTitle))];
    [aCoder encodeObject:_siteDescription forKey:NSStringFromSelector(@selector(siteDescription))];
    [aCoder encodeObject:_imageURL forKey:NSStringFromSelector(@selector(imageURL))];
    [aCoder encodeInteger:_imageWidth forKey:NSStringFromSelector(@selector(imageWidth))];
    [aCoder encodeInteger:_imageHeight forKey:NSStringFromSelector(@selector(imageHeight))];
}

//MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    QMOpenGraphItem *copy = [[QMOpenGraphItem alloc] init];
    copy.ID = [self.ID copyWithZone:zone];
    copy.baseUrl = [self.baseUrl copyWithZone:zone];
    copy.siteTitle = [self.siteTitle copyWithZone:zone];
    copy.siteDescription = [self.siteDescription copyWithZone:zone];
    copy.imageURL = [self.imageURL copyWithZone:zone];
    copy.imageWidth = self.imageWidth;
    copy.imageHeight = self.imageHeight;
    copy.faviconUrl = self.faviconUrl;
    
    return copy;
}

@end
