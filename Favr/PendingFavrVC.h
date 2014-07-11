//
//  PendingFavrVC.h
//  Favr
//
//  Created by Taranjit Singh on 17/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "CreateFavrVC.h"
#import "Parse/Parse.h"
#import "MBProgressHUD.h"
#import "FavrInfoVC.h"

#import "ChatUserListVC.h"

@interface PendingFavrVC : UIViewController<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>
{
    MBProgressHUD *hud;
    UILabel *favourNumberLabel;
    UILabel *profileNameLabel;
    UIButton *profileInfoBtn;
    BOOL editingModeOn;
    NSMutableArray *indexArray;
    int   rowNumber;
    
    NSMutableArray *outgoingFavrListArray;
    NSMutableArray *outgoingFavrUserInfo;
    NSMutableArray *tempOutgoingFavrListArray;
    
    NSMutableArray *incomingFavrListArray;
    NSMutableArray *incomingFavrUserArray;
    NSMutableArray *tempIncomingFavrListArray;
    
    UITableViewController *tableViewController;
    UIRefreshControl *refresh;
    BOOL pullToRefreshBool;
    
    UIAlertView *incomingOutgoingAlert;
}


//@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;


@property(nonatomic,weak)IBOutlet UITableView* tableView;
@property(nonatomic,weak)IBOutlet UINavigationBar* navigationBar;
@property(nonatomic,weak)IBOutlet UISegmentedControl* segmentControl;

-(IBAction)listIncomingOutgoing:(UISegmentedControl*)sender;
- (IBAction)deleteButtonAction:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarBtnObj;
- (IBAction)newFavrAct:(UIBarButtonItem *)sender;
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *newFavrBtnObj;

@end
