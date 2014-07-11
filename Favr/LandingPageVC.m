//
//  LandingPageVC.m
//  Favr
//
//  Created by Ankush on 10/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "LandingPageVC.h"
#import "AccessContactVC.h"
#import "ContactsData.h"
#import "CountryListDataSource.h"
#import <Parse/Parse.h>
#import "AddressBookUI/AddressBookUI.h"
#import "UIImageView+WebCache.h"
#import "ContactUserDetailVC.h"
#import "TSActionSheet.h"
#import "TSPopoverController.h"

@interface LandingPageVC ()
@property(nonatomic,strong)NSArray* arrContacts;
@property(nonatomic,strong)NSMutableDictionary* dictFilteredContacts;
@property(nonatomic,strong)NSArray* arrHeaders;
@property(nonatomic,strong)NSArray* allKeys;
@end

@implementation LandingPageVC


static NSString const *kMsgContact = @"CONTACT";
static NSString const *kMsgGroup = @"GROUP";



#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(get_vrns) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refresh;
    
    pullToRefreshBool = NO;
    
    
    self.createAGroupObj.hidden = YES;
    self.tableView.hidden = YES;
    self.segmentControl.hidden = YES;
    self.goObj.hidden = YES;
    self.mobileNumberTxtFld.hidden = YES;
    self.countryCodeObj.hidden = YES;
    self.countryCodePickerView.hidden = YES;
    self.mobileNumberTxtFld.delegate = self;
    
    tableRect = self.tableView.frame;
    
    findFriendArray = [[NSMutableArray alloc] init];
    
    contact_group =[NSString stringWithFormat:@"%@",kMsgContact];
    
//    pickerDataArray ;
    
    NSString *fetchedStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"fetchedStatus"];
    if ([fetchedStatus isEqualToString:nil])
    {
        
        UIAlertView *fetchAlert = [[UIAlertView alloc] initWithTitle:@"What is your phone number?"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Continue", nil];
        [fetchAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [fetchAlert show];
    }
    else if ([fetchedStatus isEqualToString:@"yes"])
    {
        self.fetchFriendListFirstTimeObj.hidden = YES;
        self.tableView.hidden = NO;
        self.segmentControl.hidden = NO;
        
        findFriendArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"contactDetails"]];
        self.arrContacts = [[AccessContactVC sharedManager] userContacts];
        self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
        
        UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
        [self.navigationController.navigationBar.topItem setTitleView:titleView];
        self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
        
        for(NSString* str in self.arrHeaders){
            NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
            //   NSLog(@"Pred Str = %@",strPred);
            NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
            NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
            //   NSLog(@"Count  = %d", tempArr.count);
            if(tempArr.count>0)
                [self.dictFilteredContacts setObject:tempArr forKey:str];
        }
        NSLog(@"Dict = %@",self.dictFilteredContacts);
        NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
        
        self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.loginSignupFlag == 2)
    {
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
//        [[NSUserDefaults standardUserDefaults] setObject:phoneNumbers forKey:@"mobileNumbers"];
        NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"mobileNumbers"];
        
        [PFCloud callFunctionInBackground:@"findFriends"
                           withParameters:@{@"mobileNumbers": phoneNumber,
                                            @"userId": userId
                                            }
                                    block:^(NSArray *results, NSError *error) {
                                        
                                        
                                        for (int i = 0; i < results.count; i++)
                                        {
                                            tempArray = [[NSMutableArray alloc] init];
                                            [tempArray addObject:[[results objectAtIndex:i] objectForKey:@"fullName"]];
                                            [tempArray addObject:[[results objectAtIndex:i] valueForKey:@"userMobileNo"]];
                                            [tempArray addObject:[[results objectAtIndex:i] valueForKey:@"profilePicPath"]];
                                            [tempArray addObject:[[results objectAtIndex:i] valueForKey:@"objectId"]];
                                            [findFriendArray addObject:tempArray];
                                        }
                                        NSLog(@"Find Friend Array %@", findFriendArray);
                                        
                                        [[NSUserDefaults standardUserDefaults] setObject:findFriendArray forKey:@"contactDetails"];
                                        //                                                                            NSLog(@"name %@, number %@", [[results objectAtIndex:0] objectForKey:@"fullName"], [[results objectAtIndex:0] valueForKey:@"userMobileNo"]);
                                        
                                        if (!error) {
                                            //                                                                                NSLog(@"result: %i",[results integerValue]);
                                            
                                            
                                            self.tableView.hidden = NO;
                                            self.segmentControl.hidden = NO;
                                            self.fetchFriendListFirstTimeObj.hidden = YES;
                                            
                                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"fetchedStatus"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            self.arrContacts = [[AccessContactVC sharedManager] userContacts];
                                            self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
                                            
                                            UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
                                            [self.navigationController.navigationBar.topItem setTitleView:titleView];
                                            self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
                                            
                                            for(NSString* str in self.arrHeaders){
                                                NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
                                                //   NSLog(@"Pred Str = %@",strPred);
                                                NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
                                                NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
                                                //   NSLog(@"Count  = %d", tempArr.count);
                                                if(tempArr.count>0)
                                                    [self.dictFilteredContacts setObject:tempArr forKey:str];
                                            }
                                            NSLog(@"Dict = %@",self.dictFilteredContacts);
                                            
                                            NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
                                            
                                            self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                                            [self.tableView reloadData];
                                            
                                            
                                            //                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
                                            //                                            {
                                            //                                                [hud hide:YES];
                                            //                                                [self showAlertWithText:@"Favr" :results];
                                            //                                            }
                                            //                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
                                            //                                            {
                                            //                                                [hud hide:YES];
                                            //                                                [self showAlertWithText:@"Favr" :results];
                                            //                                            }
                                            //                                            else{
                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
                                            ////                                                [[NSUserDefaults standardUserDefaults]synchronize];
                                            ////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
                                            //
                                            //                                            }
                                            
                                            
                                        }
                                    }] ;
    }

}


-(void) get_vrns
{
    
    pullToRefreshBool = YES;
    [self contactGroupSegmentAct:self.segmentControl];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    popupView.hidden = NO;
    self.mobileNumberTxtFld.text = @"";
}

#pragma mark - UITextfield Delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.countryCodePickerView.hidden = YES;
    return YES;
}




#pragma mark - Fetch Friend list

- (IBAction)fetchFriendListFirstTimeAct:(UIButton *)sender
{
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.fetchFriendListFirstTimeObj.hidden = YES;
    self.countryCodeObj.hidden = NO;
    self.mobileNumberTxtFld.hidden = NO;
    self.goObj.hidden = NO;
    
    //    UIAlertView *fetchAlert = [[UIAlertView alloc] initWithTitle:@"What is your phone number?"
    //                                                         message:nil
    //                                                        delegate:self
    //                                               cancelButtonTitle:@"Cancel"
    //                                               otherButtonTitles:@"Continue", nil];
    //    [fetchAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //    [fetchAlert show];
}

#pragma mark - Country Code

- (IBAction)countryCodeAct:(UIButton *)sender {
    
    CountryListDataSource *dataSource = [[CountryListDataSource alloc] init];
    pickerDataArray = [dataSource countries];
    NSLog(@"PickerDataArray %@", pickerDataArray);
    [self.countryCodePickerView reloadAllComponents];
    self.countryCodePickerView.hidden = NO;
    [self.mobileNumberTxtFld resignFirstResponder];
}



#pragma mark - UIAlertView Delegate


-(void)showAlertWithText:(NSString*)title :(NSString*)message{
    UIAlertView* validationAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [validationAlert show]
    ;
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] >= 1 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        
        
        
//        NSString *mobileNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"MobileNumber"];
        
        
//        [PFCloud callFunctionInBackground:@"findFriends"
//                           withParameters:@{@"mobileNumbers": mobileNumber}
//                                    block:^(NSString *results, NSError *error) {
//                                        if (!error) {
//                                            NSLog(@"result: %i",[results integerValue]);
//                                            
//                                            
//                                            self.tableView.hidden = NO;
//                                            self.segmentControl.hidden = NO;
//                                            self.fetchFriendListFirstTimeObj.hidden = YES;
//                                            
//                                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"fetchedStatus"];
//                                            [[NSUserDefaults standardUserDefaults] synchronize];
//                                            
//                                            self.arrContacts = [[AccessContactVC sharedManager] userContacts];
//                                            self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
//                                            
//                                            UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
//                                            [self.navigationController.navigationBar.topItem setTitleView:titleView];
//                                            self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
//                                            
//                                            for(NSString* str in self.arrHeaders){
//                                                NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
//                                                //   NSLog(@"Pred Str = %@",strPred);
//                                                NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
//                                                NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
//                                                //   NSLog(@"Count  = %d", tempArr.count);
//                                                if(tempArr.count>0)
//                                                    [self.dictFilteredContacts setObject:tempArr forKey:str];
//                                            }
//                                            NSLog(@"Dict = %@",self.dictFilteredContacts);
//                                            NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
//                                            
//                                            self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//                                            [self.tableView reloadData];
//                                            
//                                            
//                                            //                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
//                                            //                                            {
//                                            //                                                [hud hide:YES];
//                                            //                                                [self showAlertWithText:@"Favr" :results];
//                                            //                                            }
//                                            //                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
//                                            //                                            {
//                                            //                                                [hud hide:YES];
//                                            //                                                [self showAlertWithText:@"Favr" :results];
//                                            //                                            }
//                                            //                                            else{
//                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
//                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
//                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
//                                            ////                                                [[NSUserDefaults standardUserDefaults]synchronize];
//                                            ////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
//                                            //                                                
//                                            //                                            }
//                                            
//                                            
//                                        }
//                                    }] ;

        
        
        
        
        
        
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
        NSString *verifyCode = [[alertView textFieldAtIndex:0] text];
        NSLog(@"userId %@, Verify Code %@", userId, verifyCode);
        
        [PFCloud callFunctionInBackground:@"verifyCode"
                           withParameters:@{
                                            @"userId": userId,
                                            @"verifyCode":verifyCode
                                            }
                                    block:^(NSString *results, NSError *error) {
                                        if ([results integerValue] == 0)
                                        {
                                            NSLog(@"result: %li",(long)[results integerValue]);
                                            
                                            
                                            self.tableView.hidden = NO;
                                            self.segmentControl.hidden = NO;
                                            self.fetchFriendListFirstTimeObj.hidden = YES;
                                            
                                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"fetchedStatus"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            self.arrContacts = [[AccessContactVC sharedManager] userContacts];
                                            self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
                                            
                                            UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
                                            [self.navigationController.navigationBar.topItem setTitleView:titleView];
                                            self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
                                            
                                            for(NSString* str in self.arrHeaders){
                                                NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
                                                //   NSLog(@"Pred Str = %@",strPred);
                                                NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
                                                NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
                                                //   NSLog(@"Count  = %d", tempArr.count);
                                                if(tempArr.count>0)
                                                    [self.dictFilteredContacts setObject:tempArr forKey:str];
                                            }
                                            NSLog(@"Dict = %@",self.dictFilteredContacts);
                                            NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
                                            
                                            self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                                            [self.tableView reloadData];
                                            
                                            
                                            //                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
                                            //                                            {
                                            //                                                [hud hide:YES];
                                            //                                                [self showAlertWithText:@"Favr" :results];
                                            //                                            }
                                            //                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
                                            //                                            {
                                            //                                                [hud hide:YES];
                                            //                                                [self showAlertWithText:@"Favr" :results];
                                            //                                            }
                                            //                                            else{
                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
                                            ////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
                                            ////                                                [[NSUserDefaults standardUserDefaults]synchronize];
                                            ////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
                                            //                                                
                                            //                                            }
                                            
                                            
                                        }
                                        else
                                        {
//                                            [self showAlertWithText:@"Message" :@"Verification code is not correct"];
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:phoneNumbers forKey:@"mobileNumbers"];
                                            
                                            [PFCloud callFunctionInBackground:@"findFriends"
                                                               withParameters:@{@"mobileNumbers": phoneNumbers,
                                                                                @"userId": userId
                                                                                }
                                                                        block:^(NSArray *results, NSError *error) {
                                                                            
                                                                            
                                                                            for (int i = 0; i < results.count; i++)
                                                                            {
                                                                                tempArray = [[NSMutableArray alloc] init];
                                                                                [tempArray addObject:[[results objectAtIndex:i] objectForKey:@"fullName"]];
                                                                                [tempArray addObject:[[results objectAtIndex:i] valueForKey:@"userMobileNo"]];
                                                                                [tempArray addObject:[[results objectAtIndex:i] valueForKey:@"profilePicPath"]];
                                                                                [tempArray addObject:[[results objectAtIndex:i] valueForKey:@"objectId"]];
                                                                                [findFriendArray addObject:tempArray];
                                                                            }
                                                                            NSLog(@"Find Friend Array %@", findFriendArray);
                                                                            
                                                                            [[NSUserDefaults standardUserDefaults] setObject:findFriendArray forKey:@"contactDetails"];
//                                                                            NSLog(@"name %@, number %@", [[results objectAtIndex:0] objectForKey:@"fullName"], [[results objectAtIndex:0] valueForKey:@"userMobileNo"]);
                                                                            
                                                                            if (!error) {
//                                                                                NSLog(@"result: %i",[results integerValue]);
                                                                                
                                                                                
                                                                                self.tableView.hidden = NO;
                                                                                self.segmentControl.hidden = NO;
                                                                                self.fetchFriendListFirstTimeObj.hidden = YES;
                                                                                
                                                                                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"fetchedStatus"];
                                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                
                                                                                self.arrContacts = [[AccessContactVC sharedManager] userContacts];
                                                                                self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
                                                                                
                                                                                UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
                                                                                [self.navigationController.navigationBar.topItem setTitleView:titleView];
                                                                                self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
                                                                                
                                                                                for(NSString* str in self.arrHeaders){
                                                                                    NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
                                                                                    //   NSLog(@"Pred Str = %@",strPred);
                                                                                    NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
                                                                                    NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
                                                                                    //   NSLog(@"Count  = %d", tempArr.count);
                                                                                    if(tempArr.count>0)
                                                                                        [self.dictFilteredContacts setObject:tempArr forKey:str];
                                                                                }
                                                                                NSLog(@"Dict = %@",self.dictFilteredContacts);
                                                                                
                                                                                NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
                                                                                
                                                                                self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                                                                                [self.tableView reloadData];
                                                                                
                                                                                
                                                                                //                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
                                                                                //                                            {
                                                                                //                                                [hud hide:YES];
                                                                                //                                                [self showAlertWithText:@"Favr" :results];
                                                                                //                                            }
                                                                                //                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
                                                                                //                                            {
                                                                                //                                                [hud hide:YES];
                                                                                //                                                [self showAlertWithText:@"Favr" :results];
                                                                                //                                            }
                                                                                //                                            else{
                                                                                ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
                                                                                ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
                                                                                ////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
                                                                                ////                                                [[NSUserDefaults standardUserDefaults]synchronize];
                                                                                ////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
                                                                                //                                                
                                                                                //                                            }
                                                                                
                                                                                
                                                                            }
                                                                        }] ;

                                        }
                                        
//                                        if (!error) {
//                                            NSLog(@"result: %i",[results integerValue]);
//                                            
//                                            
//                                            self.tableView.hidden = NO;
//                                            self.segmentControl.hidden = NO;
//                                            self.fetchFriendListFirstTimeObj.hidden = YES;
//                                            
//                                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"fetchedStatus"];
//                                            [[NSUserDefaults standardUserDefaults] synchronize];
//                                            
//                                            self.arrContacts = [[AccessContactVC sharedManager] userContacts];
//                                            self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
//                                            
//                                            UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
//                                            [self.navigationController.navigationBar.topItem setTitleView:titleView];
//                                            self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
//                                            
//                                            for(NSString* str in self.arrHeaders){
//                                                NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
//                                                //   NSLog(@"Pred Str = %@",strPred);
//                                                NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
//                                                NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
//                                                //   NSLog(@"Count  = %d", tempArr.count);
//                                                if(tempArr.count>0)
//                                                    [self.dictFilteredContacts setObject:tempArr forKey:str];
//                                            }
//                                            NSLog(@"Dict = %@",self.dictFilteredContacts);
//                                            NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
//                                            
//                                            self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//                                            [self.tableView reloadData];
//                                            
//                                            
////                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
////                                            {
////                                                [hud hide:YES];
////                                                [self showAlertWithText:@"Favr" :results];
////                                            }
////                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
////                                            {
////                                                [hud hide:YES];
////                                                [self showAlertWithText:@"Favr" :results];
////                                            }
////                                            else{
//////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
//////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
//////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
//////                                                [[NSUserDefaults standardUserDefaults]synchronize];
//////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
////                                                
////                                            }
//                                            
//                                            
//                                        }
                                    }] ;
        
        
        
        
    }
    else if (buttonIndex == 0)
    {
        self.fetchFriendListFirstTimeObj.hidden = NO;
    }
}




#pragma mark - UITableView Delegate

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    
//    return [self.allKeys count];
//}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [self.allKeys objectAtIndex:section];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([contact_group isEqualToString:(NSString *)kMsgContact])
    {
        return findFriendArray.count;
    }
    else if ([contact_group isEqualToString:(NSString *)kMsgGroup])
    {
        return 0;
    }
    return 0;
//    NSString* currentKey = [self.allKeys objectAtIndex:section];
//    NSArray* tempArr = [self.dictFilteredContacts objectForKey:currentKey];
//    return tempArr.count;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellIdent = [NSString stringWithFormat:@"CellIdent"];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
//    NSString* currentKey = [self.allKeys objectAtIndex:indexPath.section];
//    NSArray* tempContactArr = [self.dictFilteredContacts objectForKey:currentKey];
//    
//    NSString* fname =((ContactsData*)[tempContactArr objectAtIndex:indexPath.row]).firstNames;
//    NSString* lName =((ContactsData*)[tempContactArr objectAtIndex:indexPath.row]).lastNames;
    
    if ([contact_group isEqualToString:(NSString *)kMsgContact])
    {
        cell.textLabel.text = [[findFriendArray objectAtIndex:indexPath.row] objectAtIndex:0];
        
        cell.imageView.layer.cornerRadius = 30.0f;
        cell.imageView.layer.masksToBounds=YES;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[findFriendArray objectAtIndex:indexPath.row] objectAtIndex:2]] placeholderImage:[UIImage imageNamed:@"profileImage.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        
        cell.textLabel.textColor = [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0];
    }
    else if ([contact_group isEqualToString:(NSString *) kMsgGroup])
    {
        
    }
    
    
    return cell;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50.0f;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 30.0f;
//}
//
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
//    /* Create custom view to display section header... */
//    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 25, 25)];
//    [label setFont:[UIFont systemFontOfSize:16]];
//    [label setTextColor:[UIColor whiteColor]];
//    NSString *string =[self.allKeys objectAtIndex:section];
//    /* Section header is in 0th index... */
//    [label setText:string];
//    [circleView addSubview:label];
//    circleView.layer.cornerRadius = 17.0f;
//    circleView.layer.masksToBounds=YES;
//    [view setBackgroundColor:[UIColor clearColor]];
//    [circleView setBackgroundColor: [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0]];
//    [view addSubview:circleView];
//    return view;
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactUserDetailVC *contactUserDetailVC = [[ContactUserDetailVC alloc] init];
    [self.navigationController pushViewController:contactUserDetailVC animated:YES];
    contactUserDetailVC.userId = [[findFriendArray objectAtIndex:indexPath.row] objectAtIndex:3];
}



#pragma mark - UIPickerView Delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component

{
//    NSInteger rows;
//    if (0 == component)
//        rows = 10;
//    else if (1 == component)
//        rows = 10;
//    else
//        rows = 15;
    return [pickerDataArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //NSString *temp;
    
    
    //temp = [[NSString alloc] initWithString:[self.pocModelData.arrayOfDistricts objectAtIndex:row]];
    if (0 == component)
    {
//        NSLog(@"String returned is %@ for row %d for component %d", [self.pocModelData.arrayOfDistricts objectAtIndex:row], row, component);
        return  [[pickerDataArray objectAtIndex:row] valueForKey:kCountryName];
    }
    else if
        (1 == component){
//            NSLog(@"String returned is %@ for row %d for component %d", [self.pocModelData.arrayOfDistricts objectAtIndex:row], row, component);
//            return [self.pocModelData.arrayOfDistricts objectAtIndex:row];
        }else{
//            NSLog(@"String returned is %@ for row %d for component %d", [self.pocModelData.arrayOfDistricts objectAtIndex:row], row, component);
//            return [self.pocModelData.arrayOfDistricts objectAtIndex:row];
        }
    //return temp;
    //  return [self.pocModelData.arrayOfDistricts objectAtIndex:row];
    return nil;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    NSLog(@"row %i", row);
    NSString *item;  // = [[pickerDataArray objectAtIndex:row] valueForKey:kCountryCallingCode];
    if (row == 197)
    {
        item = @"+672";
    }
    else
    {
        item = [[pickerDataArray objectAtIndex:row] valueForKey:kCountryCallingCode];
    }
//    if ([[[pickerDataArray objectAtIndex:row] valueForKey:kCountryCallingCode] isEqualToString:@"<null>"])
//    {
//        item = @"011";
//    }
//    else
//    {
//        item = [[pickerDataArray objectAtIndex:row] valueForKey:kCountryCallingCode];
//    }
    
    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"%.2f USD = %.2f %@", dollars, result,
//                              [countryNames objectAtIndex:row]];
    [self.countryCodeObj setTitle:item forState:UIControlStateNormal];
}





#pragma mark - Other Method

-(NSArray *)getAllContacts
{
    
    CFErrorRef *error = nil;
    
    
    phoneNumbers = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        
        for (int i = 0; i < nPeople; i++)
        {
            ContactsData *contacts = [ContactsData new];
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            //get First Name and Last Name
            
            @try {
                if(!(ABRecordCopyValue(person, kABPersonFirstNameProperty)== NULL)){
                    NSString* fName = [NSString stringWithFormat:@"%@",ABRecordCopyValue(person, kABPersonFirstNameProperty)];
                    contacts.firstNames = fName;
                }
                
                NSString* lName = [NSString stringWithFormat:@"%@",ABRecordCopyValue(person, kABPersonLastNameProperty)];
                contacts.lastNames =  lName;
            }
            @catch (NSException *exception) {
                NSLog(@"error is: %@", exception);
            }
            @finally {
                
            }
            
            
            if (!contacts.firstNames) {
                contacts.firstNames = @"";
            }
            if (!contacts.lastNames) {
                contacts.lastNames = @"";
            }
            
            // get contacts picture, if pic doesn't exists, show standart one
            
            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
            contacts.image = [UIImage imageWithData:imgData];
            if (!contacts.image) {
                contacts.image = [UIImage imageNamed:@"NOIMG.png"];
            }
            //get Phone Numbers
            
//            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                NSString *phNo = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *pN = [phNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [phoneNumbers addObject:pN];
//                [phoneNumbers addObject:phoneNumber];
                
                //NSLog(@"All numbers %@", phoneNumbers);
                
            }
            
            
            
            [contacts setNumbers:phoneNumbers];
            
            //get Contact email
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
                // NSLog(@"All emails are:%@", contactEmails);
                
            }
            
            [contacts setEmails:contactEmails];
            
            
            
//            NSLog(@"phone Numbers %@", contacts.firstNames);
            
            [items addObject:contacts];
            
#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif
            
            
            
            
        }
        
        NSLog(@"phone contact %@", phoneNumbers);
        return items;
        
        
        
    }
    else
    {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
        return NO;
        
        
    }
    
}


- (IBAction)goAct:(UIButton *)sender {
    
    NSLog(@"phone contact%@", [self getAllContacts]);
    
    self.countryCodePickerView.hidden = YES;
    [self.mobileNumberTxtFld resignFirstResponder];
    
    self.countryCodeObj.hidden = YES;
    self.mobileNumberTxtFld.hidden = YES;
    self.goObj.hidden = YES;
    
    NSString *mobileNumber = [[NSString alloc] initWithFormat:@"%@%@",self.countryCodeObj.titleLabel.text, self.mobileNumberTxtFld.text];
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    NSLog(@"mobile number %@ user id %@", mobileNumber, userId);
    
    self.mobileNumberTxtFld.text = @"";
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    
    [PFCloud callFunctionInBackground:@"sendVerificationCodee"
                       withParameters:@{@"number": mobileNumber,
                                        @"userId": userId
                                        }
                                block:^(NSString *results, NSError *error) {
                                    [hud hide:YES];
                                    
                                        NSLog(@"result: %@",results);
                                        
                                        if(![results integerValue])
                                        {
                                            [hud hide:YES];
                                            [self showAlertWithText:@"Favr" :@"We couldn't connect to the server"];
                                        }
                                        
                                        else
                                        {
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:mobileNumber forKey:@"MobileNumber"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            [hud hide:YES];
                                            UIAlertView *fetchAlert = [[UIAlertView alloc] initWithTitle:@"Please enter code?"
                                                                      message:nil
                                                                      delegate:self
                                                                      cancelButtonTitle:@"Cancel"
                                                                      otherButtonTitles:@"Continue", nil];
                                            [fetchAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                                            [[fetchAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
                                            [fetchAlert show];
                                            
                                            
//                                            [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
//                                            [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
//                                            [[NSUserDefaults standardUserDefaults]synchronize];
//                                            [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
                                            
                                        }
                                        
                                    
                                }];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)createAGroupAction:(UIButton *)sender {
    CreateFavrGroupVC *createFavrGroupVC = [[CreateFavrGroupVC alloc] init];
    [self.navigationController pushViewController:createFavrGroupVC animated:YES];
}

- (IBAction)contactGroupSegmentAct:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex==0)
    {
        [refresh endRefreshing];
        self.tableView.frame = tableRect;
        self.createAGroupObj.hidden = YES;
        contact_group =[NSString stringWithFormat:@"%@",kMsgContact];
    }
    else
    {
        [refresh endRefreshing];
        self.tableView.frame = tableRect;
        CGRect rect = self.tableView.frame;
        self.createAGroupObj.hidden = NO;
        rect.origin.y = rect.origin.y+40;
        rect.size.height = rect.size.height-40;
        self.tableView.frame = rect;
        contact_group =[NSString stringWithFormat:@"%@",kMsgGroup];
    }
    [self.tableView reloadData];
}




-(IBAction)reloadContactsTableView:(id)sender forEvent:(UIEvent*)event
{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.view.frame = CGRectMake(0,0, 100, 200);
    
    
    popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, 190)];
    
    UIButton *singleFavrSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    singleFavrSelectBtn.frame = CGRectMake(15, 20, 35, 35);
    [singleFavrSelectBtn setBackgroundImage:[UIImage imageNamed:@"single"] forState:UIControlStateNormal];
    [singleFavrSelectBtn addTarget:self action:@selector(singleFavrSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    singleFavrSelectBtn.tag = 1;
    [popupView addSubview:singleFavrSelectBtn];
    
    
    UIButton *multipleFavrSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    multipleFavrSelectBtn.frame = CGRectMake(15, 75, 35, 35);
    [multipleFavrSelectBtn setBackgroundImage:[UIImage imageNamed:@"multiple"] forState:UIControlStateNormal];
    [multipleFavrSelectBtn addTarget:self action:@selector(singleFavrSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    multipleFavrSelectBtn.tag = 2;
    [popupView addSubview:multipleFavrSelectBtn];
    
    
    
    UIButton *groupFavrSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    groupFavrSelectBtn.frame = CGRectMake(15, 130, 40, 40);
    [groupFavrSelectBtn setBackgroundImage:[UIImage imageNamed:@"group"] forState:UIControlStateNormal];
    [groupFavrSelectBtn addTarget:self action:@selector(singleFavrSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    groupFavrSelectBtn.tag = 3;
    [popupView addSubview:groupFavrSelectBtn];
    
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithView:popupView];
    popoverController.cornerRadius = 5;
//    popoverController.titleText = @"change order";
    popoverController.popoverBaseColor = [UIColor lightGrayColor];
    popoverController.popoverGradient= NO;
    //    popoverController.arrowPosition = TSPopoverArrowPositionHorizontal;
    [popoverController showPopoverWithTouch:event];
    
    
//    TSActionSheet *actionSheet = [[TSActionSheet alloc] initWithTitle:@"action sheet"];
//    [actionSheet destructiveButtonWithTitle:@"hoge" block:nil];
//    [actionSheet addButtonWithTitle:@"hoge1" block:^{
//        NSLog(@"pushed hoge1 button");
//    }];
//    [actionSheet addButtonWithTitle:@"moge2" block:^{
//        NSLog(@"pushed hoge2 button");
//    }];
//    [actionSheet cancelButtonWithTitle:@"Cancel" block:nil];
//    actionSheet.cornerRadius = 5;
//    [actionSheet showWithTouch:event];
    
    
    [self.tableView reloadData];
}



-(void) singleFavrSelectBtnAction: (UIButton *)sender
{
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.groupSelected = sender.tag;
    
    CreateFavrVC *createFavrVC = [[CreateFavrVC alloc] init];
    [self.navigationController pushViewController:createFavrVC animated:YES];
    
}

-(void) multipleFavrSelectBtnAction: (UIButton *)sender
{
    CreateFavrVC *createFavrVC = [[CreateFavrVC alloc] init];
    [self.navigationController pushViewController:createFavrVC animated:YES];
}

-(void) groupFavrSelectBtnAction: (UIButton *)sender
{
    CreateFavrVC *createFavrVC = [[CreateFavrVC alloc] init];
    [self.navigationController pushViewController:createFavrVC animated:YES];
}


@end
