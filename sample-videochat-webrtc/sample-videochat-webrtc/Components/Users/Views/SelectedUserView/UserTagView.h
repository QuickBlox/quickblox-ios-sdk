//
//  UserTagView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 03.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CancelHandler)(NSUInteger iD);

@interface UserTagView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) CancelHandler onCancelTapped;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *userID;
@end

NS_ASSUME_NONNULL_END
