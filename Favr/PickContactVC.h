//
//  PickContactVC.h
//  Favr
//
//  Created by Ankush on 01/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "Parse/Parse.h"
#import "MBProgressHUD.h"
#import "PendingFavrVC.h"

@interface PickContactVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    NSArray *contactListArray;
    int rowNumber;
    NSArray *selectedRows;
    NSString *contact_Group;
    NSMutableArray *addedFavrListArray;
    MBProgressHUD *hud;
    NSString *dateString;
    UIAlertView *statusAlert;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSString *favrTitleString;
@property (strong, nonatomic) NSString *favrDescriptionString;
- (IBAction)backBtnAct:(UIBarButtonItem *)sender;
- (IBAction)backBtnAction:(UIBarButtonItem *)sender;
- (IBAction)doneBtnAct:(UIBarButtonItem *)sender;

- (IBAction)contactGroupSegmentControl:(UISegmentedControl *)sender;

@end
