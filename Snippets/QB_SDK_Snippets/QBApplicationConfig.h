//
//  QBApplicationConfig.h
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 7/9/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

//#ifdef __i386__ // 32 bit simulator
//    #define UseTestUser1
//#endif
//#ifdef __LP64__ // 64 bit simulator
//    #define UseTestUser1
//#endif

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
#define testUserID1 1501966
#define testUserLogin1 @"igorquickblox3"
#define testUserPassword1 @"igorquickblox3"
#define testUserEmail1 @"igorquickblox3@gmail.com"
#define testUserPasswordForChat1 testUserPassword1
//
#define testUserID2 1501969
#define testUserLogin2 @"igorquickblox4"
#define testUserPassword2 @"igorquickblox4"
#define testUserEmail2 @"igorquickblox4@gmail.com"
#define testUserPasswordForChat2 testUserPassword2
//
#define testRoomJID @"92_53fe05c5535c12666f01336d@muc.chat.quickblox.com"


//#define AppID 99
//#define AuthKey @"63ebrp5VZt7qTOv"
//#define AuthSecret @"YavMAxm5T59-BRw"
//#define AccountKey @"7yvNe17TnjNUqDoPwfqp"
////
//#define ServerApiDomain nil
//#define ServerChatDomain nil
//#define ContentBucket nil
////
//#define testUserID1 1624805
//#define testUserLogin1 @"igorquickblox3"
//#define testUserPassword1 @"igorquickblox3"
//#define testUserEmail1 @"igorquickblox3@gmail.com"
//#define testUserPasswordForChat1 testUserPassword1
////
//#define testUserID2 1624806
//#define testUserLogin2 @"igorquickblox4"
//#define testUserPassword2 @"igorquickblox4"
//#define testUserEmail2 @"igorquickblox4@gmail.com"
//#define testUserPasswordForChat2 testUserPassword2
////
//#define testRoomJID @"92_53fe05c5535c12666f01336d@muc.chat.quickblox.com"

//#define AppID 6
//#define AuthKey @"4EGTYEqm6ESVRVV"
//#define AuthSecret @"Zh7mgXWzLxamK8x"
//#define AccountKey @"w2sqDxVtLx9UJLmzBHGH"
////
//#define ServerApiDomain @"http://api.stage.quickblox.com"
//#define ServerChatDomain @"chatstage.quickblox.com"
//#define ContentBucket @"blobs-test-oz"
////
//#define testUserID1 1529438
//#define testUserLogin1 @"igorquickblox66"
//#define testUserPassword1 @"igorquickblox66"
//#define testUserEmail1 @"igorquickblox66@gmail.com"
//#define testUserPasswordForChat1 testUserPassword1
////
//#define testUserID2 1529437
//#define testUserLogin2 @"igorquickblox5"
//#define testUserPassword2 @"igorquickblox5"
//#define testUserEmail2 @"igorquickblox5@mail.com"
//#define testUserPasswordForChat2 testUserPassword2
////
//#define testRoomJID @"54228b56efa357f62e000048"


#ifdef UseTestUser1
    #define UserID1 testUserID1
    #define UserLogin1 testUserLogin1
    #define UserPassword1 testUserPassword1
    #define UserEmail1 testUserEmail1
    #define UserPasswordForChat1 testUserPasswordForChat1

    #define UserID2 testUserID2
    #define UserLogin2 testUserLogin2
    #define UserPassword2 testUserPassword2
    #define UserEmail2 testUserEmail2
    #define UserPasswordForChat2 testUserPasswordForChat2
#else
    #define UserID1 testUserID2
    #define UserLogin1 testUserLogin2
    #define UserPassword1 testUserPassword2
    #define UserEmail1 testUserEmail2
    #define UserPasswordForChat1 testUserPasswordForChat2

    #define UserID2 testUserID1
    #define UserLogin2 testUserLogin1
    #define UserPassword2 testUserPassword1
    #define UserEmail2 testUserEmail1
    #define UserPasswordForChat2 testUserPasswordForChat1
#endif

