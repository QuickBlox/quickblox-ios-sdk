//
//  QBChatAttachment+QMCustomData.m
//  QMServices
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import "QBChatAttachment+QMCustomData.h"
#import <objc/runtime.h>
#import "QMSLog.h"

@implementation QBChatAttachment (QMCustomData)

- (NSMutableDictionary *)context {
    
    NSMutableDictionary *context = objc_getAssociatedObject(self, @selector(context));
    
    if (!context) {
        
        context = [self _jsonObject];
        [self setContext:context];
    }
    
    return context;
}

- (void)setContext:(NSMutableDictionary *)context {
    
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)synchronize {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.context
                                                       options:0
                                                         error:&error];
    
    if (error != nil) {
        
        QMSLog(@"Error serializing data to JSON: %@", error);
        return;
    }
    
    self.data = [[NSString alloc] initWithData:jsonData
                                      encoding:NSUTF8StringEncoding];
}

#pragma mark - Private

- (NSMutableDictionary *)_jsonObject {
    
    NSError *error = nil;
    NSData *jsonData = [self.data dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        
        NSDictionary *representationObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:0
                                                                               error:&error];
        
        if (error != nil) {
            
            QMSLog(@"Error serializing JSON to data: %@", error);
            return [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *mutableObject = [representationObject mutableCopy];
        
        // removing possible null values
        [representationObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * __unused stop) {
            
            if (obj == [NSNull null]) {
                
                [mutableObject removeObjectForKey:key];
            }
        }];
        
        return mutableObject;
    }
    else {
        
        return [[NSMutableDictionary alloc] init];
    }
}

@end
