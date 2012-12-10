//
//  QBASIAuthenticationDialog.h
//  Part of QBASIHTTPRequest -> http://allseeing-i.com/QBASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QBASIHTTPRequest;

typedef enum _QBASIAuthenticationType {
	QBASIStandardAuthenticationType = 0,
    QBASIProxyAuthenticationType = 1
} QBASIAuthenticationType;

@interface QBASIAutorotatingViewController : UIViewController
@end

@interface QBASIAuthenticationDialog : QBASIAutorotatingViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	QBASIHTTPRequest *request;
	QBASIAuthenticationType type;
	UITableView *tableView;
	UIViewController *presentingController;
	BOOL didEnableRotationNotifications;
}
+ (void)presentAuthenticationDialogForRequest:(QBASIHTTPRequest *)request;
+ (void)dismiss;

@property (retain) QBASIHTTPRequest *request;
@property (assign) QBASIAuthenticationType type;
@property (assign) BOOL didEnableRotationNotifications;
@property (retain, nonatomic) UIViewController *presentingController;
@end
