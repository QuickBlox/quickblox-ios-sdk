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
@property (nonatomic, weak) QBUUser* user;

@property (nonatomic, strong) IBOutlet UITextField* loginFiled;
@property (nonatomic, strong) IBOutlet UITextField* fullNameField;
@property (nonatomic, strong) IBOutlet UITextField* phoneField;
@property (nonatomic, strong) IBOutlet UITextField* emailField;
@property (nonatomic, strong) IBOutlet UITextField* websiteField;
@property (nonatomic, strong) IBOutlet UITextField *tagsField;

@property (nonatomic, strong) IBOutlet MainViewController* mainController;

- (IBAction) update:(id)sender;
- (IBAction) back:(id)sender;
- (IBAction) hideKeyboard:(id)sender;

@end
