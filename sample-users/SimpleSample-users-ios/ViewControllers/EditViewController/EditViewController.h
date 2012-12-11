//
//  EditViewController.h
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class enables update QB user
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@class MainViewController;

@interface EditViewController : UIViewController <QBActionStatusDelegate>{
}
@property (nonatomic, assign) QBUUser* user;

@property (nonatomic, retain) IBOutlet UITextField* loginFiled;
@property (nonatomic, retain) IBOutlet UITextField* fullNameField;
@property (nonatomic, retain) IBOutlet UITextField* phoneField;
@property (nonatomic, retain) IBOutlet UITextField* emailField;
@property (nonatomic, retain) IBOutlet UITextField* websiteField;
@property (nonatomic, retain) IBOutlet UITextField *tagsField;

@property (nonatomic, retain) IBOutlet MainViewController* mainController;

- (IBAction) update:(id)sender;
- (IBAction) back:(id)sender;
- (IBAction) hideKeyboard:(id)sender;

@end
