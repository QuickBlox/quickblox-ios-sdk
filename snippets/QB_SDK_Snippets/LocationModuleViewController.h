//
//  LocationModuleViewController.h
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/12/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationModuleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>{
    IBOutlet UITableView *tableView;
}

@end
