//
//  FavrInfoVC.m
//  Favr
//
//  Created by Ankush on 03/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "FavrInfoVC.h"
#import "MyChattingVC.h"
#import "ChatSharedManager.h"

@interface FavrInfoVC ()
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSString *opponetChatUserId;
@end

@implementation FavrInfoVC
@synthesize favrId;
@synthesize navigationTitle;
@synthesize incoming_outgoingString;

static NSString const *kMsgIncomming = @"INCOMMING";
static NSString const *kMsgOutgoing = @"OUTGOING";

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
    NSLog(@"favrID %@", favrId);
    
    self.users = [[ChatSharedManager sharedManager] chatUsers];
    
    self.navigationBar.topItem.title = navigationTitle;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    [PFCloud callFunctionInBackground:@"getFavrDetail"
                       withParameters:@{@"favrId": favrId}
                                block:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        NSLog(@"favr Details %@", [results objectAtIndex:0]);
                                        favrInfoArray = [[NSArray alloc] initWithArray:results];
                                        [hud hide:YES];
                                        self.favrTitleLbl.text = [[results objectAtIndex:0] objectForKey:@"favrTitle"];
                                        self.favrDescLabel.text = [[results objectAtIndex:0] objectForKey:@"favrDescription"];
                                    }
                                }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (self.pendingFavrStatus == 1)
    {
        if ([incoming_outgoingString isEqualToString:(NSString *) kMsgIncomming])
        {
            self.favrAcceptBtnObj.hidden = NO;
            self.favrRejectButtonObj.hidden = NO;
        }
        else if ([incoming_outgoingString isEqualToString:(NSString *) kMsgOutgoing])
        {
            self.favrAcceptBtnObj.hidden = YES;
            self.favrRejectButtonObj.hidden = YES;
        }
    }
    
    else if (self.pendingFavrStatus == 2)
    {
        if ([incoming_outgoingString isEqualToString:(NSString *) kMsgIncomming])
        {
            self.favrAcceptBtnObj.hidden = YES;
            self.favrRejectButtonObj.hidden = YES;
        }
        else if ([incoming_outgoingString isEqualToString:(NSString *) kMsgOutgoing])
        {
            self.favrAcceptBtnObj.hidden = YES;
            self.favrRejectButtonObj.hidden = YES;
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnAct:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)FavrRejectedBtnAct:(UIButton *)sender {
    [PFCloud callFunctionInBackground:@"rejectFavr"
                       withParameters:@{@"favrId": favrId}
                                block:^(NSString *results, NSError *error) {
                                    if ([results intValue])
                                    {
                                        [self.navigationController popViewControllerAnimated:YES];
                                        //                                        NSLog(@"favr Details %@", [results objectAtIndex:0]);
                                        //                                        favrInfoArray = [[NSArray alloc] initWithArray:results];
                                        //                                        [hud hide:YES];
                                        //                                        self.favrTitleLbl.text = [[results objectAtIndex:0] objectForKey:@"favrTitle"];
                                        //                                        self.favrDescLabel.text = [[results objectAtIndex:0] objectForKey:@"favrDescription"];
                                    }
                                }];
}

- (IBAction)favrAcceptedBtnAct:(UIButton *)sender {
    
    [PFCloud callFunctionInBackground:@"acceptFavr"
                       withParameters:@{@"favrId": favrId}
                                block:^(NSString *results, NSError *error) {
                                    if ([results intValue])
                                    {
                                        [self.navigationController popViewControllerAnimated:YES];
//                                        NSLog(@"favr Details %@", [results objectAtIndex:0]);
//                                        favrInfoArray = [[NSArray alloc] initWithArray:results];
//                                        [hud hide:YES];
//                                        self.favrTitleLbl.text = [[results objectAtIndex:0] objectForKey:@"favrTitle"];
//                                        self.favrDescLabel.text = [[results objectAtIndex:0] objectForKey:@"favrDescription"];
                                    }
                                }];
    
}

- (IBAction)favrChatBtnAct:(UIButton *)sender {
//    MyChattingVC *chattingVC = (MyChattingVC*)[mainStoryboard
//                                               instantiateViewControllerWithIdentifier: @"MyChattingVC"];
//    
//    QBUUser *user = (QBUUser *)self.users;
//    
//    MyChattingVC *chattingVC = [[MyChattingVC alloc] init];
//    chattingVC.opponent = user;
//    //    [[SlideNavigationController sharedInstance] pushViewController:chattingVC animated:YES];z
//    [self.navigationController pushViewController:chattingVC animated:YES];
    
    
    
    if ([incoming_outgoingString isEqualToString:(NSString *)kMsgIncomming])
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        [PFCloud callFunctionInBackground:@"getDetailUser"
                           withParameters:@{
                                            @"userId": [[favrInfoArray objectAtIndex:0] valueForKey:@"helpeeId"]
                                            }
                                    block:^(NSArray *results, NSError *error)
         {
             
             if (!error)
             {
                 [hud hide:YES];
                 NSLog(@"result array %@", results);
                 NSLog(@"[results objectAtIndex:0] %@", [results objectAtIndex:0]);
                 NSLog(@"[[results objectAtIndex:0] valueForKey:email] %@", [[results objectAtIndex:0] valueForKey:@"emailAddr"]);
                 
                 NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
                 NSString *resultString = [[[[results objectAtIndex:0] valueForKey:@"emailAddr"] componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"."];
                 NSLog (@"Result: %@", resultString);
                 
                 self.opponetChatUserId = resultString;
                 NSLog(@"email Id %@", self.opponetChatUserId);
                 
                 [self chatScreen];
                 
             }
             else
             {
                 NSLog(@"Error Occured");
             }
         }
         ];
    }
    else if ([incoming_outgoingString isEqualToString:(NSString *)kMsgOutgoing])
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        [PFCloud callFunctionInBackground:@"getDetailUser"
                           withParameters:@{
                                            @"userId": [[favrInfoArray objectAtIndex:0] valueForKey:@"helperId"]
                                            }
                                    block:^(NSArray *results, NSError *error)
         {
             
             if (!error)
             {
                 [hud hide:YES];
                 NSLog(@"result array %@", results);
                 NSLog(@"[results objectAtIndex:0] %@", [results objectAtIndex:0]);
                 NSLog(@"[[results objectAtIndex:0] valueForKey:email] %@", [[results objectAtIndex:0] valueForKey:@"emailAddr"]);
                 
                 NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
                 NSString *resultString = [[[[results objectAtIndex:0] valueForKey:@"emailAddr"] componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"."];
                 NSLog (@"Result: %@", resultString);
                 
                 self.opponetChatUserId = resultString;
                 NSLog(@"email Id %@", self.opponetChatUserId);
                 
                 [self chatScreen];
                 
             }
             else
             {
                 NSLog(@"Error Occured");
             }
         }
         ];
    }
    
    
//    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.labelText = @"Loading";
//    [PFCloud callFunctionInBackground:@"getDetailUser"
//                       withParameters:@{
//                                        @"userId": [[favrInfoArray objectAtIndex:0] valueForKey:@"helperId"]
//                                        }
//                        block:^(NSArray *results, NSError *error)
//                        {
//                            
//                            if (!error)
//                            {
//                                [hud hide:YES];
//                                NSLog(@"result array %@", results);
//                                NSLog(@"[results objectAtIndex:0] %@", [results objectAtIndex:0]);
//                                NSLog(@"[[results objectAtIndex:0] valueForKey:email] %@", [[results objectAtIndex:0] valueForKey:@"emailAddr"]);
//                                
//                                NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
//                                NSString *resultString = [[[[results objectAtIndex:0] valueForKey:@"emailAddr"] componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"."];
//                                NSLog (@"Result: %@", resultString);
//                                
//                                self.opponetChatUserId = resultString;
//                                NSLog(@"email Id %@", self.opponetChatUserId);
//                                
//                                [self chatScreen];
//                                
//                            }
//                            else
//                            {
//                                NSLog(@"Error Occured");
//                            }
//                        }
//     ];
    
}
-(void) chatScreen
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"mainStoryboard"
															 bundle: nil];
	
	MyChattingVC *chattingVC = (MyChattingVC*)[mainStoryboard
                                               instantiateViewControllerWithIdentifier: @"MyChattingVC"];
    
    
    for (int i = 0; i < self.users.count; i++)
    {
        NSLog(@"self.user.count %@", [self.users objectAtIndex:i]);
        if ([[[self.users objectAtIndex:i] valueForKey:@"login"] isEqualToString:self.opponetChatUserId])
        {
            
            QBUUser *user = (QBUUser *)[self.users objectAtIndex:i];
            chattingVC.opponent = user;
            [self.navigationController pushViewController:chattingVC animated:YES];
            break;
        }
    }
    
//    QBUUser *user = (QBUUser *)self.users[selectedIndex];
//    
//    chattingVC.opponent = user;
//    [[SlideNavigationController sharedInstance] pushViewController:chattingVC animated:YES];
}
@end
