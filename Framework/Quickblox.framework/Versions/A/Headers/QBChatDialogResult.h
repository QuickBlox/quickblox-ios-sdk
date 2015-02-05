//
//  QBChatDialogResult.h
//  Quickblox
//
//  Created by Igor Alefirenko on 14/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBResult.h"

/** QBChatDialogResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to the user after he made ​​the request for create/update dialog. */

@class QBChatDialog;
@interface QBChatDialogResult : QBResult

/** An instance of QBChatDialog */
@property (nonatomic, readonly) QBChatDialog *dialog;

@end
