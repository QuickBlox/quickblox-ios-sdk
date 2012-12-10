//
//  UsersModuleViewController.h
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersModuleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>{
    IBOutlet UITableView *tableView;
}

@end
