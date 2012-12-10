//
//  AppDelegate.h
//  TURN
//
//  Created by Igor Khomenko on 9/19/12.
//  Copyright (c) 2012 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TURNClient.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, TURNClientDelegate>{
    TURNClient *turnClient;
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpSocket;
}

@end
