//
//  QBApplicationConfig.h
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 7/9/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#define UseTestUser1


// Shared
//
#define AppID 92
#define AuthKey @"wJHdOcQSxXQGWx5"
#define AuthSecret @"BTFsj7Rtt27DAmT"
#define AccountKey @"7yvNe17TnjNUqDoPwfqp"
//
#define ServerApiDomain nil
#define ServerChatDomain nil
#define ContentBucket nil
//
#define testUserID1 1279282
#define testUserLogin1 @"igorquickblox"
#define testUserPassword1 @"igorquickblox"
#define testUserPasswordForChat1 testUserPassword1
//
#define testUserID2 1279283
#define testUserLogin2 @"igorquickblox2"
#define testUserPassword2 @"igorquickblox2"
#define testUserPasswordForChat2 testUserPassword2
//
#define testRoomJID @"92_53c3d547535c12e74c0024b1@muc.chat.quickblox.com"


#ifdef UseTestUser1
    #define UserID1 testUserID1
    #define UserLogin1 testUserLogin1
    #define UserPassword1 testUserPassword1
    #define UserPasswordForChat1 testUserPasswordForChat1

    #define UserID2 testUserID2
    #define UserLogin2 testUserLogin2
    #define UserPassword2 testUserPassword2
    #define UserPasswordForChat2 testUserPasswordForChat2
#else
    #define UserID1 testUserID2
    #define UserLogin1 testUserLogin2
    #define UserPassword1 testUserPassword2
    #define UserPasswordForChat1 testUserPasswordForChat2

    #define UserID2 testUserID1
    #define UserLogin2 testUserLogin1
    #define UserPassword2 testUserPassword1
    #define UserPasswordForChat2 testUserPasswordForChat1
#endif

