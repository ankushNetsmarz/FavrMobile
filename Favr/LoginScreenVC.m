//
//  LoginScreenVC.m
//  Favr
//
//  Created by Taranjit Singh on 27/05/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//
@import QuartzCore;
#import "LoginScreenVC.h"
#import "AccessContactVC.h"
#import "SocialSyncVC.h"
#import <Parse/Parse.h>
#import "signUp.h"
#import "ChatSharedManager.h"

@interface LoginScreenVC ()

@end


@implementation LoginScreenVC

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
	// Do any additional setup after loading the view.
   
    self.mySwitch.transform = CGAffineTransformMakeScale(0.80, 0.60);
    
    self.btnLogin.layer.cornerRadius = 15.0f;
    self.btnLogin.layer.masksToBounds=YES;
    
    self.btnSignUp.layer.cornerRadius = 15.0f;
    self.btnSignUp.layer.masksToBounds=YES;
    
    self.passwordView.layer.cornerRadius = 15.0f;
    self.passwordView.layer.masksToBounds=YES;
    self.userNameView.layer.cornerRadius = 15.0f;
    self.userNameView.layer.masksToBounds=YES;
    NSString* usrProfImagePath = @"~/Documents/userFBImage.png";
    UIImage* tempImage = [UIImage imageWithContentsOfFile:[usrProfImagePath stringByExpandingTildeInPath]];
    //[[AccessContactVC sharedManager] userFBImage];
    self.userFBPic.image = tempImage;
    self.userFBPic.layer.cornerRadius = 50.0f;
    self.userFBPic.layer.masksToBounds=YES;
    self.txtEmailId.text = [[AccessContactVC sharedManager] userFBEmail];
    self.txtUserName = [[AccessContactVC sharedManager] userFBName];
    
}
- (IBAction)signMeUp:(id)sender {
    
}
- (IBAction)logMeUp:(id)sender {
    
    if(![self validateFields])
        return;
    NSLog(@"email: %@", _txtEmailId.text);
    
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    NSString *resultString = [[self.txtEmailId.text componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"."];
    NSLog (@"Result: %@", resultString);

    NSString* chatUserName = resultString;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    
    [PFCloud callFunctionInBackground:@"logIn"
                       withParameters:@{@"emailId": self.txtEmailId.text,
                                        @"pwd":self.txtPassword.text
                                        }
                                block:^(NSArray *results, NSError *error)
    {
                                    if (!error)
                                {
//                                        NSLog(@"result: %@",results);
//                                        
//                                        if([results isEqualToString:@"You are not registered with us, try SignUp!"])
//                                        {
//                                            [hud hide:YES];
//                                             [self showAlertWithText:@"Favr" :results];
//                                        }
//                                        else if([results isEqualToString:@"Username/Password doesnt match !"])
//                                        {
//                                            [hud hide:YES];
//                                            [self showAlertWithText:@"Favr" :results];
//                                        }
//                                        else
//                                        {
                                            [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
                                            [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
                                            [[NSUserDefaults standardUserDefaults] setObject:[[results objectAtIndex:0] valueForKey:@"objectId"] forKey:@"userId"];
                                            NSLog(@"userid %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]);
                                            [[NSUserDefaults standardUserDefaults] setObject:[results valueForKey:@"userMobileNo"] forKey:@"mobileNumbers"];
                                    
                                            [[NSUserDefaults standardUserDefaults]synchronize];
                                             [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
                                            [[ChatSharedManager sharedManager] setTxtUserName:chatUserName];
                                            [[ChatSharedManager sharedManager] setTxtUserPassword:self.txtPassword.text];
                                            [[ChatSharedManager sharedManager] loginChatFunction:@"LOGIN"];
                                    
                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                    appDelegate.loginSignupFlag = 2;
                                           
//                                        }
                                    
                                    }
        
    }
    ];
}

-(BOOL)validateFields{
     
    if(self.txtEmailId.text.length == 0 ){
        [self showAlertWithText:@"Error" :@"Please enter a valid Email Address"];
        return NO;
    }
    if(self.txtPassword.text.length==0){
        [self showAlertWithText:@"Error" :@"Please enter valid password!"];
        return NO;
    }
    
    return YES;
}

-(void)showAlertWithText:(NSString*)title :(NSString*)message{
    UIAlertView* validationAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [validationAlert show]
    ;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    CGPoint point = CGPointMake(0,0);
    [self.mailViewScroll setContentOffset:point animated:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGPoint point = CGPointMake(0,152);
    [self.mailViewScroll setContentOffset:point animated:YES];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"gotoSignUpScreen"]){
        signUp* destVC = (signUp*)[segue destinationViewController];
        destVC.txtEmail.text= self.txtEmailId.text;
        destVC.txtPassword.text = self.txtPassword.text;
        destVC.usrEmail= self.txtEmailId.text;
        destVC.usrName = self.txtUserName;
        destVC.usrPasswd= self.txtPassword.text;
        destVC.profileImage = self.userFBPic.image;
    }
}
@end
