//
//  QBChatDialogAnswer.h
//  Quickblox
//
//  Created by Igor Alefirenko on 14/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@class QBChatDialog;
@interface QBChatDialogAnswer : XmlAnswer {
    NSMutableArray *occupantsIds;
    NSMutableDictionary *data;
}

@property (nonatomic, retain) QBChatDialog *dialog;

@end
