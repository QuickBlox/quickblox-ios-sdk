//
//  QBAVCallPermissions.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 29/06/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "QBAVCallPermissions.h"

@implementation QBAVCallPermissions

+ (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType
                                completion:(PermissionBlock)completion {
    
#if (TARGET_IPHONE_SIMULATOR)
    completion(YES);
    return;
#endif
    
    [self requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        
        if (granted) {
            
            switch (conferenceType) {
                    
                case QBRTCConferenceTypeAudio:
                    
                    if (completion) {
                        
                        completion(granted);
                    }
                    
                    break;
                    
                case QBRTCConferenceTypeVideo: {
                    
                    [self requestPermissionToCameraWithCompletion:^(BOOL videoGranted) {
                        
                        if (!videoGranted) {
                            
                            // showing error alert with a suggestion
                            // to go to the settings
                            [self showAlertWithTitle:NSLocalizedString(@"Camera error", nil)
                                             message:NSLocalizedString(@"The app doesn't have access to the camera, please go to settings and enable it.", nil)];
                        }
                        
                        if (completion) {
                            
                            completion(videoGranted);
                        }
                    }];
                    
                    break;
                }
            }
        }
        else {
            // showing error alert with a suggestion
            // to go to the settings
            [self showAlertWithTitle:NSLocalizedString(@"Microphone error", nil)
                             message:NSLocalizedString(@"The app doesn't have access to the microphone, please go to settings and enable it.", nil)];
            
            if (completion) {
                
                completion(granted);
            }
        }
    }];
}

+ (void)requestPermissionToMicrophoneWithCompletion:(PermissionBlock)completion {
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{completion(granted);});
        }
    }];
}

+ (void)requestPermissionToCameraWithCompletion:(PermissionBlock)completion {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (authStatus) {
            
        case AVAuthorizationStatusNotDetermined: {
            
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{completion(granted);});
                }
            }];
            
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            
            if (completion) {
                completion(NO);
            }
            
            break;
            
        case AVAuthorizationStatusAuthorized:
            
            if (completion) {
                completion(YES);
            }
            
            break;
    }
}

#pragma mark - Helpers

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction * _Nonnull __unused action){/*Empty action*/}]
     ];
    
    [alertController addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil)
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * _Nonnull __unused action) {
                                
                                NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                [[UIApplication sharedApplication] openURL:settingsUrl];
                            }]
     ];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController
                                                                                 animated:YES
                                                                               completion:nil];
}

@end
