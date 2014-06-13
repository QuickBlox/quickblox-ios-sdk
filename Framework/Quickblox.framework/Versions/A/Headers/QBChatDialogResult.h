//
//  QBChatDialogResult.h
//  Quickblox
//
//  Created by Igor Alefirenko on 14/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "Result.h"

@class QBChatDialog;
@interface QBChatDialogResult : Result

@property (nonatomic, readonly) QBChatDialog *dialog;

@end
