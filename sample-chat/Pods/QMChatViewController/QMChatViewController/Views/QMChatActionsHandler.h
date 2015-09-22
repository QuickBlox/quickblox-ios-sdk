//
//  QMChatActionsHandler.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 29.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMChatActionsHandler <NSObject>

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender;

@end
