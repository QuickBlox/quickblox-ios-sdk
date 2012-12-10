//
//  QBASessionCreationQuery.h
//  AuthService
//
//  Created by Igor Khomenko on 2/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBASessionCreationRequest;
@interface QBASessionCreationQuery : QBAAuthQuery{
    QBASessionCreationRequest *sessionCreationRequest;
}

@property (nonatomic,readonly) QBASessionCreationRequest *sessionCreationRequest;

-(id)initWithRequest:(QBASessionCreationRequest *)_sessionCreationRequest;

-(void)signRequest:(RestRequest *)request;

@end
