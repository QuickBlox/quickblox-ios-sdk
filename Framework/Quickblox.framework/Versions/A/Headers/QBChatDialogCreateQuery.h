//
//  QBChatDialogCreateQuery.h
//  Quickblox
//
//  Created by Igor Alefirenko on 14/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBChatQuery.h"

@class QBChatDialog;
@interface QBChatDialogCreateQuery : QBChatQuery

@property (nonatomic, retain) QBChatDialog *dialog;

- (id)initWithDialog:(QBChatDialog *)dialog;


@end
