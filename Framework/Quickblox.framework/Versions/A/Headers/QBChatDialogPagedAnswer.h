//
//  QBDialogsAnswer.h
//  Quickblox
//
//  Created by Igor Alefirenko on 25/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@class QBChatDialogAnswer;
@interface QBChatDialogPagedAnswer : XmlAnswer {
    QBChatDialogAnswer *dialogAnswer;
}

@property (nonatomic, readonly) NSMutableArray *dialogs;

@end
