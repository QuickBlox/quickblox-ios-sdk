//
//  QBASession.h/Users/bogdan/Documents/git/SDK-ios/Framework/Quickblox.xcodeproj
//  AuthService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBCEntity.h"

/** QBASession class declaration  */
/** Overview:*/
/** This class represents session information. */

@interface QBASession : QBCEntity <NSCoding, NSCopying>{
@private
    NSString *token;
    NSUInteger applicationID;
    NSUInteger userID;
    NSUInteger deviceID;
    NSUInteger timestamp;
    NSInteger nonce;
}

/** Unique auto generated sequence of numbers which identify API User as the legitimate user of our system. It is used in relatively short periods of time and can be easily changed. We grant API Users some rights after authentication and check them based on this token. */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *token;

/** Applicarion identifier */
@property (nonatomic, assign) NSUInteger applicationID;

/** User identifier */
@property (nonatomic, assign) NSUInteger userID;

/** Device identifier */
@property (nonatomic, assign) NSUInteger deviceID;

/** Unix Timestamp. It shouldn't be differ from time provided by NTP more than 10 minutes. We suggest you synchronize time on your devices with NTP service. */
@property (nonatomic, assign) NSUInteger timestamp;

/** Unique Random Value. Requests with the same timestamp and same value for nonce parameter can not be send twice. */
@property (nonatomic, assign) NSInteger nonce;

@end
