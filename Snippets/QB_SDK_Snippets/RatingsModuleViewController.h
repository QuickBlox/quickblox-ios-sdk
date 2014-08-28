//
//  RatingsModuleViewController.h
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingsModuleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>{
    IBOutlet UITableView *tableView;
}
@end
