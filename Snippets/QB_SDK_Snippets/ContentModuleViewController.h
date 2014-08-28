//
//  ContentModuleViewController.h
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/18/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentModuleViewController : UIViewController<UITableViewDelegate, QBActionStatusDelegate>{
     IBOutlet UITableView *tableView;
}

@end
