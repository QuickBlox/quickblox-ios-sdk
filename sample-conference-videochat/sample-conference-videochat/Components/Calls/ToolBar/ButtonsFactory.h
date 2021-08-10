//
//  ButtonsFactory.h
//  sample-conference-videochat
//
//  Created by Injoit on 23/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomButton.h"

@interface ButtonsFactory : NSObject

+ (CustomButton *)videoEnable;
+ (CustomButton *)auidoEnable;
+ (CustomButton *)screenShare;
+ (CustomButton *)swapCam;
+ (CustomButton *)decline;

@end
