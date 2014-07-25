//
//  RichContentViewController.h
//  SimpleSample Messages
//
//  Created by Ruslan on 9/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class downloads rich push content and shows it
//

#import <UIKit/UIKit.h>
#import "SSMPushMessage.h"

@interface RichContentViewController : UIViewController <QBActionStatusDelegate>{
    int imageNumber;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *downloadProgress;
@property (strong, nonatomic) SSMPushMessage *message;

- (IBAction)back:(id)sender;

@end
