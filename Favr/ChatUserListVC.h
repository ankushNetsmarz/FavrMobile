//
//  ChatUserListVC.h
//  Favr
//
//  Created by Ankush on 08/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatUserListVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)backBtnAct:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
