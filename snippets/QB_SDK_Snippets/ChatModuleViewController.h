//
//  ChatModuleViewController.h
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatModuleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, QBChatDelegate>{
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) QBChatRoom *testRoom;
@end   