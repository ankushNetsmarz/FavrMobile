//
//  CreateFavrGroupVC.h
//  Favr
//
//  Created by Ankush on 04/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "Parse/Parse.h"
#import "MBProgressHUD.h"
#import "GroupNameAndDetailVC.h"

@interface CreateFavrGroupVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *groupMemberArray;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *contactList;
- (IBAction)nextButtonAction:(UIBarButtonItem *)sender;
- (IBAction)backButtonAct:(UIBarButtonItem *)sender;
@end
