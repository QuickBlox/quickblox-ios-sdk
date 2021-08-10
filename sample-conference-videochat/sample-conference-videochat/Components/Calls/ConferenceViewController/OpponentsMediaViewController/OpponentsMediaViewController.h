//
//  OpponentsMediaViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 19.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "BaseUsersViewController.h"
#import "BaseCallViewController.h"
#import "CallParticipant.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MuteUserHandler)(BOOL isMuted, NSNumber *userID);

@interface OpponentsMediaViewController : BaseUsersViewController<BaseCallViewControllerDelegate>
@property (strong, nonatomic) NSString *dialogID;
@property (nonatomic, strong) MuteUserHandler didPressMuteUser;

- (instancetype)initWithDialogID:(NSString *)dialogID users:(NSArray<CallParticipant *> *)users;
@end

NS_ASSUME_NONNULL_END
