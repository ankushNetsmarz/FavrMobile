//
//  signUp.m
//  Favr
//
//  Created by Ankush on 10/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "signUp.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "ChatSharedManager.h"
@interface signUp ()
{
    MBProgressHUD *HUD;
}
@end

@implementation signUp
@synthesize usrEmail, usrPasswd;
@synthesize profileImage, usrName;

static int const KAllInputField = 5;

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
    self.txtFullName.text = self.usrName;
    self.txtEmail.text = self.usrEmail;
    self.txtPassword.text=self.usrPasswd;
    self.profileImageView.image = self.profileImage;
    self.profileImageView.layer.cornerRadius = 38.0f;
    self.profileImageView.layer.masksToBounds=YES;
    
    
    for(UIView* view in self.mainScrollView.subviews){
        if (view.tag == KAllInputField) {
            view.layer.cornerRadius= 15.0f;
            view.layer.masksToBounds=YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelSignUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)signUpUser:(UIButton *)sender {
    if(![self validateFields])
        return;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    NSData *imagedata = UIImagePNGRepresentation(self.profileImageView.image);
    NSString *encodedBase64Image = [imagedata base64Encoding];
    NSString* userEmail =self.txtEmail.text;
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    NSLog(@"email: %@", self.txtEmail.text);
    [PFCloud callFunctionInBackground:@"singUp"
       withParameters:@{@"emailId": self.txtEmail.text,
                        @"pwd":self.txtPassword.text,
                        @"fullName": self.txtFullName.text,
                        @"profileImage": encodedBase64Image}
                block:^(NSString *results, NSError *error) {
//                    if (!error) {
                        NSLog(@"result: %@",results);
                        
                        if([results isEqualToString:@"You are already registered, Try LogIn !"])
                        {
                            [hud hide:YES];
                            [self showAlertWithText:@"Favr" :results];
                        }
                        else{
                            
                            NSString *resultString = [[userEmail componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"."];
                            NSLog (@"Result: %@", resultString);
                            NSString* chatUserName = resultString;
                            
                            [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
                            [[NSUserDefaults standardUserDefaults] setObject:self.txtEmail.text forKey:@"loggedInUserEmail"];
                            [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            [self performSegueWithIdentifier:@"socialPage"  sender:nil];
                            [HUD hide:YES];
                            
                            [[ChatSharedManager sharedManager] setTxtUserName:chatUserName];
                            [[ChatSharedManager sharedManager] setTxtUserPassword:self.txtPassword.text];
                            [[ChatSharedManager sharedManager] loginChatFunction:@"REGISTER"];

                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            appDelegate.loginSignupFlag = 1;
                            
                        }
                        
//                    }
                }];
}

-(BOOL)validateFields{
    if(self.txtFullName.text.length == 0 ){
        [self showAlertWithText:@"Error" :@"Please enter a valid Full name"];
        return NO;
    }
    if(self.txtEmail.text.length == 0 ){
        [self showAlertWithText:@"Error" :@"Please enter a valid Email Address"];
        return NO;
    }
     
    return YES;
}

-(void)showAlertWithText:(NSString*)title :(NSString*)message{
    UIAlertView* validationAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [validationAlert show]
    ;
}
- (void)showLoadingWithLabel{
	HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading";


}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    CGPoint point = CGPointMake(0,0);
    [self.mainScrollView setContentOffset:point animated:YES];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGPoint point = CGPointMake(0,152);
    [self.mainScrollView setContentOffset:point animated:YES];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)profileImageAct:(UIButton *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.profileImageView.image = image;
    //Or you can get the image url from AssetsLibrary
//    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
