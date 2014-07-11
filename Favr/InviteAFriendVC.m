//
//  InviteAFriendVC.m
//  Favr
//
//  Created by Ankush on 03/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "InviteAFriendVC.h"

@interface InviteAFriendVC ()

@end

@implementation InviteAFriendVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    contactArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"contactDetails"]];
    NSLog(@"contact array %@", contactArray);
    findFriendArray = [[NSMutableArray alloc] init];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    NSString *phoneNumbers = [[NSUserDefaults standardUserDefaults] valueForKey:@"mobileNumbers"];
    
    [PFCloud callFunctionInBackground:@"findFriends"
                       withParameters:@{@"mobileNumbers": phoneNumbers}
                                block:^(NSArray *results, NSError *error) {
                                    
                                    
                                    if (!error)
                                    {
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
                                        [self.tableView reloadData];
                                        [hud hide:YES];
                                        [[NSUserDefaults standardUserDefaults] setObject:findFriendArray forKey:@"contactDetails"];
                                    }
                                    
                                    //                                                                            NSLog(@"name %@, number %@", [[results objectAtIndex:0] objectForKey:@"fullName"], [[results objectAtIndex:0] valueForKey:@"userMobileNo"]);
                                    
//                                    if (!error) {
//                                        //                                                                                NSLog(@"result: %i",[results integerValue]);
//                                        
//                                        
//                                        self.tableView.hidden = NO;
//                                        self.segmentControl.hidden = NO;
//                                        self.fetchFriendListFirstTimeObj.hidden = YES;
//                                        
//                                        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"fetchedStatus"];
//                                        [[NSUserDefaults standardUserDefaults] synchronize];
//                                        
//                                        self.arrContacts = [[AccessContactVC sharedManager] userContacts];
//                                        self.dictFilteredContacts =[[NSMutableDictionary alloc]init];
//                                        
//                                        UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrNavIcon"]];
//                                        [self.navigationController.navigationBar.topItem setTitleView:titleView];
//                                        self.arrHeaders = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
//                                        
//                                        for(NSString* str in self.arrHeaders){
//                                            NSString* strPred = [NSString stringWithFormat:@"firstNames BEGINSWITH '%@'",str];
//                                            //   NSLog(@"Pred Str = %@",strPred);
//                                            NSPredicate *namesBeginning = [NSPredicate predicateWithFormat:strPred];
//                                            NSArray* tempArr =[self.arrContacts filteredArrayUsingPredicate:namesBeginning];
//                                            //   NSLog(@"Count  = %d", tempArr.count);
//                                            if(tempArr.count>0)
//                                                [self.dictFilteredContacts setObject:tempArr forKey:str];
//                                        }
//                                        NSLog(@"Dict = %@",self.dictFilteredContacts);
//                                        
//                                        NSArray* tempAllKeys = [self.dictFilteredContacts allKeys];
//                                        
//                                        self.allKeys = [tempAllKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//                                        [self.tableView reloadData];
//                                        
//                                        
//                                        //                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
//                                        //                                            {
//                                        //                                                [hud hide:YES];
//                                        //                                                [self showAlertWithText:@"Favr" :results];
//                                        //                                            }
//                                        //                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
//                                        //                                            {
//                                        //                                                [hud hide:YES];
//                                        //                                                [self showAlertWithText:@"Favr" :results];
//                                        //                                            }
//                                        //                                            else{
//                                        ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
//                                        ////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
//                                        ////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
//                                        ////                                                [[NSUserDefaults standardUserDefaults]synchronize];
//                                        ////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
//                                        //
//                                        //                                            }
//                                        
//                                        
//                                    }
                                }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [findFriendArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[findFriendArray objectAtIndex:indexPath.row] objectAtIndex:0];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[findFriendArray objectAtIndex:indexPath.row] objectAtIndex:2]] placeholderImage:[UIImage imageNamed:@"profileImage.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    cell.imageView.layer.cornerRadius = 27.0f;
    cell.imageView.layer.masksToBounds=YES;
    
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnAct:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
