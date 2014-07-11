//
//  LandingPageVC.h
//  Favr
//
//  Created by Ankush on 10/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "CreateFavrGroupVC.h"
#import "CreateFavrVC.h"

@interface LandingPageVC : UIViewController <UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    NSArray *pickerDataArray;
    MBProgressHUD *hud;
    NSMutableArray *phoneNumbers;
    NSMutableArray *findFriendArray;
    NSMutableArray *tempArray;
    NSString *contact_group;
    CGRect tableRect;
    UITableViewController *tableViewController;
    UIRefreshControl *refresh;
    BOOL pullToRefreshBool;
    
    NSMutableArray *groupDetailsArray;
    UIView *popupView;
}
@property(nonatomic,weak)IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property(nonatomic,weak)IBOutlet UINavigationBar* navigationBar;
@property (strong, nonatomic) IBOutlet UIButton *fetchFriendListFirstTimeObj;
@property (strong, nonatomic) IBOutlet UIButton *countryCodeObj;
@property (strong, nonatomic) IBOutlet UITextField *mobileNumberTxtFld;
@property (strong, nonatomic) IBOutlet UIButton *goObj;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *countryCodePickerView;
@property (strong, nonatomic) IBOutlet UIButton *createAGroupObj;

- (IBAction)fetchFriendListFirstTimeAct:(UIButton *)sender;
- (IBAction)countryCodeAct:(UIButton *)sender;
- (IBAction)goAct:(UIButton *)sender;
- (IBAction)createAGroupAction:(UIButton *)sender;
- (IBAction)contactGroupSegmentAct:(UISegmentedControl *)sender;
-(IBAction)reloadContactsTableView:(id)sender forEvent:(UIEvent*)event;



@end
