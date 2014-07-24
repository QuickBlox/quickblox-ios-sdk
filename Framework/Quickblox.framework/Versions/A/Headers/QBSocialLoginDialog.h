//
//  QBSocialLoginDialog.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/30/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SocialLoginAnswer;

@class QBSocialLoginDialog;
@protocol QBSocialLoginDialogDelegate <NSObject>

- (void)socialLogin:(QBSocialLoginDialog *)dialog receivedXmlString:(NSString *)xmlString headers:(NSDictionary *)headers;

@end

@interface QBSocialLoginDialog : UIView <UIWebViewDelegate>{
    UIWebView* _webView;
    UIActivityIndicatorView* _spinner;
    UIButton* _closeButton;
    
    // Ensures that UI elements behind the dialog are disabled.
    UIView* _modalBackgroundView;
}
@property (retain) SocialLoginAnswer *answer;
@property (readonly) NSMutableURLRequest *request;
@property (readonly) id operation;

@property (copy) void (^onSuccessfullResponse)(NSData *jsonUser, NSDictionary* headers);

- (void) showWithHTML:(NSString *)html andBaseURL:(NSURL *)baseURL;
- (void) hide;

@end
