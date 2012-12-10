//
//  ChatModuleViewController.h
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatModuleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, QBChatDelegate>{
    QBChatRoom* testRoom;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
