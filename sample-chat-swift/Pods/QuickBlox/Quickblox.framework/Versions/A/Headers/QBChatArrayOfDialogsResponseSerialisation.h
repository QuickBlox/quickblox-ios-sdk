//
//  QBChatResponseSerialisation.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 9/1/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBJSONResponseSerialiser.h"

@interface QBChatArrayOfDialogsResponseSerialisation : QBJSONResponseSerialiser

+ (NSString *)keyUserIDs;
+ (NSString *)keyChatDialogs;

@end
