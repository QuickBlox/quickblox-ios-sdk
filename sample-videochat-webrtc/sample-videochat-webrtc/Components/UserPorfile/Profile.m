//
//  Profile.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import "Profile.h"

static NSString* const kCurrentProfile = @"curentProfile";

@interface Profile()

@property(strong, nonatomic) QBUUser *user;

@end

@implementation Profile

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.user = [Profile loadObject];
    }
    return self;
}

//MARK: - Static Methods

+ (void)clearProfile {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentProfile];
}

+ (void)synchronizeUser:(QBUUser *)user {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentProfile];
}

+ (void)updateUser:(QBUUser *)user {
    
    QBUUser *current = [Profile loadObject];
    
    if (current) {
        if (user.fullName) {
            current.fullName = user.fullName;
        }
        if (user.login) {
            current.login = user.login;
        }
        if (user.password) {
            current.password = user.password;
        }
        [Profile synchronizeUser:current];
    } else {
        [Profile synchronizeUser:current];
    }
}

//MARK: - Internal Methods
+ (QBUUser *)loadObject {
    QBUUser *user = nil;
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentProfile];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:userData error:nil];
    unarchiver.requiresSecureCoding = NO;
    user = [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    return user;
}

//MARK - Setup
- (BOOL)isFull {
    return self.user != nil;
}

- (NSUInteger)ID {
    return self.user.ID;
}

- (NSString *)login {
    return self.user.login;
}

- (NSString *)password {
    return self.user.password;
}

- (NSString *)fullName {
    return self.user.fullName;
}

- (NSString *)tag {
    return self.user.tags.firstObject;
}

@end

