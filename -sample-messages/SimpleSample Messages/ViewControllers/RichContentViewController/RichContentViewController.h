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
#import "PushMessage.h"

@interface RichContentViewController : UIViewController <QBActionStatusDelegate>{
    int imageNumber;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *downloadProgress;
@property (retain, nonatomic) PushMessage *message;

- (IBAction)back:(id)sender;

@end
