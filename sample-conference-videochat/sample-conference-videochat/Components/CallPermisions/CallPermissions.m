//
//  QBAVCallPermissions.m
//  sample-conference-videochat
//
//  Created by Injoit on 29/06/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "CallPermissions.h"

typedef void(^SettingsCompletion)(BOOL granted);

@implementation CallPermissions

+ (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType presentingViewController:(UIViewController *)presentingViewController
                                completion:(void (^)(BOOL granted))completion {
    
#if (TARGET_IPHONE_SIMULATOR)
    completion(YES);
    return;
#endif
    
    [self requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        
        if (granted == YES) {
            
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
                                             message:NSLocalizedString(@"The app doesn't have access to the camera, please go to settings and enable it.", nil)
                            presentingViewController:presentingViewController];
                        }
                        
                        if (completion) {
                            
                            completion(videoGranted);
                        }
                    }];
                    
                    break;
                }
            }
        } else {
            // showing error alert with a suggestion
            // to go to the settings
            
            [self showAlertWithTitle:NSLocalizedString(@"Microphone error", nil)
                             message:NSLocalizedString(@"The app doesn't have access to the microphone, please go to settings and enable it.", nil)
            presentingViewController:presentingViewController];
            
            if (completion) {
                
                completion(granted);
            }
        }
    }];
}

+ (void)requestPermissionToMicrophoneWithCompletion:(void (^)(BOOL granted))completion {
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{completion(granted);});
        }
    }];
}

+ (void)requestPermissionToCameraWithCompletion:(void (^)(BOOL granted))completion {
    
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
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message presentingViewController:(UIViewController *)presentingViewController {
    
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
        [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];}]
     ];
    
    [presentingViewController presentViewController:alertController
                                           animated:YES
                                         completion:nil];
}

@end
