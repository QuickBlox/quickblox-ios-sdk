//
//  AuthModuleViewController.h
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthModuleViewController : UIViewController <UITableViewDelegate, QBActionStatusDelegate>{
    IBOutlet UITableView *tableView;
}

@end
