//
//  MessagesModuleViewController.h
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/14/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesModuleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>{
    IBOutlet UITableView *tableView;
}

@end
