//
//  QBCOFileDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/10/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCOCustomObjectQuery.h"

@interface QBCOFileQuery : QBCOCustomObjectQuery{
    NSString *className;
    NSString *objectID;
    NSString *fileFieldName;
}

@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *objectID;
@property (nonatomic, readonly) NSString *fileFieldName;

- (id)initWithClassName:(NSString *)className objectID:(NSString *)objectID fileFieldName:(NSString *)fileFieldName;

@end
