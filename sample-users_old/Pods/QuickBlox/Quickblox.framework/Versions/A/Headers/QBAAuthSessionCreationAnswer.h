//
//  QBAAuthSessionCreationAnswer.h
//  AuthService
//
//  Created by Igor Khomenko on 2/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBASession;

@interface QBAAuthSessionCreationAnswer : QBAAuthAnswer{
}
@property (nonatomic, readonly) QBASession *session;

@end
