//
//  ParticipantVideoView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticipantView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParticipantVideoView : ParticipantView

//MARK: - Properties
@property (strong, nonatomic) UIView * _Nullable videoView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@end

NS_ASSUME_NONNULL_END
