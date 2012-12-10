//
//  CustomObjectsModuleViewController.h
//  QB_SDK_Snippets
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomObjectsModuleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>{
    IBOutlet UITableView *tableView;
}

@end
