//
//  QBChatMessage+QBDateDivider.m
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBChatMessage+QBDateDivider.h"

NSString const *kQBDateDividerCustomParameterKey = @"kQBDateDividerCustomParameterKey";

@interface QBChatMessage ()

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBChatMessage (QBDateDivider)
@dynamic isDateDividerMessage;


#pragma mark - Context

- (NSMutableDictionary *)context {
    
    if (!self.customParameters) {
        
        self.customParameters = [NSMutableDictionary dictionary];
    }
    
    return self.customParameters;
}

- (void)setIsDateDividerMessage:(BOOL)isDateDividerMessage {
    self.context[kQBDateDividerCustomParameterKey] = @(isDateDividerMessage);
}

- (BOOL)isDateDividerMessage {
    return [self.context[kQBDateDividerCustomParameterKey] boolValue];
}

@end
