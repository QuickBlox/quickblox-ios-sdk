//
//  QBCOFile.h
//  Quickblox
//
//  Created by Andrey Moskvin on 8/7/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBCOFileUploadInfo : NSObject

@property (nonatomic, strong) NSString *fileIdentifier;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *contentType;

@end
