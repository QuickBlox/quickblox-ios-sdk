//
//  QBChatMessage+QBDateDivider.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "QBChatMessage+QBDateDivider.h"

NSString const *kQBDateDividerCustomParameterKey = @"kQBDateDividerCustomParameterKey";

@interface QBChatMessage ()

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBChatMessage (QBDateDivider)
@dynamic isDateDividerMessage;

//MARK: - Context
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
