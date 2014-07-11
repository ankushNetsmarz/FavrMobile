//
//  FirstScreenVC.m
//  Favr
//
//  Created by Taranjit Singh on 19/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "FirstScreenVC.h"
#import "AccessContactVC.h"
#import "MBProgressHUD.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Twitter/Twitter.h"
#import "ChatSharedManager.h"

@interface FirstScreenVC ()
{
    MBProgressHUD *hud;
    BOOL defaultAccountFound;
}
@end

@implementation FirstScreenVC

static int const kUserMinOrigin = 3;
static int const kUserMaxOrigin = 173;
static int const kUserLoginAcceptDrag = 153;

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
    
    [[ChatSharedManager sharedManager] initializeChatInstance];
    UIPanGestureRecognizer* panGues = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    [panGues setMinimumNumberOfTouches:1];
    [panGues setMaximumNumberOfTouches:1];
    [panGues setDelegate:self];
    [self.imgUserLogin addGestureRecognizer:panGues];
    
    [[AccessContactVC sharedManager]setDelegate:self];
    [self setupUIForLoginVC];
    
    BOOL initiatedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"AppHasInitiatedBefore"];

    defaultAccountFound=YES;
    
    if(!initiatedBefore){
        [self askUserForContactSharing];
    }
    else{
      //[self performSelectorInBackground:@selector(askPermissionToFetchContacts) withObject:nil];
        if ( ![[NSUserDefaults standardUserDefaults] valueForKey:@"userId"] )
        {
            [self signUpUser];
        }
        NSString* usrProfImagePath = @"~/Documents/userFBImage.png";
        UIImage* tempImage = [UIImage imageWithContentsOfFile:[usrProfImagePath stringByExpandingTildeInPath]];
        self.imgUserLogin.image = tempImage;
        self.verfiedUserView.hidden=NO;
        if([[AccessContactVC sharedManager] userContacts].count ==0){
            [self performSelectorInBackground:@selector(fetchContactOnBackground) withObject:nil];
        }
    }
}

-(void)askUserForContactSharing{
    UIAlertView* fetchPhoneBK = [[UIAlertView alloc] initWithTitle:@"Fetch" message:@"Do you want this app to fetch your contact" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [fetchPhoneBK show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex ==0){
        [self performSelector:@selector(signUpUser) withObject:nil afterDelay:0.5];
    }
    
    if(buttonIndex ==1){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppHasInitiatedBefore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(askPermissionToFetchContacts) withObject:nil afterDelay:1.0];
        
    }
}
-(void)fetchContactOnBackground{
    [[AccessContactVC sharedManager] fetchContacts];
}
-(void)askPermissionToFetchContacts{
    [[AccessContactVC sharedManager] fetchContacts];
    [[AccessContactVC sharedManager] requestFacebookAccessFirstTime];
//    [self requestTwitterAccessFirstTime:@"muunnasingh"];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

}


- (void) getProfileImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
//    profileImageView.image = [UIImage imageWithData:data];
    NSLog(@"image url %@", url);
}

- (void) getBannerImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
//    bannerImageView.image = [UIImage imageWithData:data];
    NSLog(@"banner Image url %@", url);
}


     
- (void)requestTwitterAccessFirstTime:(NSString *)username
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // Creating a request to get the info about a user on Twitter
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:username forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Check if we reached the reate limit
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // Check if there was an error
                        
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                            
                            // Filter the preferred data
                            
                            NSString *screen_name = [(NSDictionary *)TWData objectForKey:@"screen_name"];
                            NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
                            
                            int followers = [[(NSDictionary *)TWData objectForKey:@"followers_count"] integerValue];
                            int following = [[(NSDictionary *)TWData objectForKey:@"friends_count"] integerValue];
                            int tweets = [[(NSDictionary *)TWData objectForKey:@"statuses_count"] integerValue];
                            
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            
                            
                            // Update the interface with the loaded data
                            
//                            nameLabel.text = name;
//                            usernameLabel.text= [NSString stringWithFormat:@"@%@",screen_name];
//                            tweetsLabel.text = [NSString stringWithFormat:@"%i", tweets];
//                            followingLabel.text= [NSString stringWithFormat:@"%i", following];
//                            followersLabel.text = [NSString stringWithFormat:@"%i", followers];
                            
                            
                            
                            NSString *lastTweet = [[(NSDictionary *)TWData objectForKey:@"status"] objectForKey:@"text"];
//                            lastTweetTextView.text= lastTweet;
                            
                            NSLog(@"name %@ \n UsernameLabel %@ \n tweetsLabel %d \n followingLabel %d \n follwersLabel %d \n lastTweet %@", name, screen_name, tweets, following, followers, lastTweet);
                            
                            
                            
                            // Get the profile image in the original resolution
                            
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            [self getProfileImageForURLString:profileImageStringURL];
                            
                            
                            // Get the banner image, if the user has one
                            
                            if (bannerImageStringURL) {
                                NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
                                [self getBannerImageForURLString:bannerURLString];
                            } else {
//                                bannerImageView.backgroundColor = [UIColor underPageBackgroundColor];
                            }
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}
//{
//    ACAccountStore *accountStore=[[ACAccountStore alloc]init];
//    //  Step 0: Check that the user has local Twitter accounts
//    if (1)
//    {
//        //  Step 1:  Obtain access to the user's Twitter accounts
//        ACAccountType *twitterAccountType = [accountStore
//                                             accountTypeWithAccountTypeIdentifier:
//                                             ACAccountTypeIdentifierTwitter];
//        [accountStore
//         requestAccessToAccountsWithType:twitterAccountType
//         options:NULL
//         completion:^(BOOL granted, NSError *error) {
//             if (granted) {
//                 //  Step 2:  Create a request
//                 NSArray *twitterAccounts =
//                 [accountStore accountsWithAccountType:twitterAccountType];
//                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
//                               @"/1.1/statuses/user_timeline.json"];
//                 NSDictionary *params = @{@"screen_name" : username,
//                                          @"include_rts" : @"0",
//                                          @"trim_user" : @"1",
//                                          @"count" : @"1"};
//                 SLRequest *request =
//                 [SLRequest requestForServiceType:SLServiceTypeTwitter
//                                    requestMethod:SLRequestMethodGET
//                                              URL:url
//                                       parameters:params];
//                 
//                 //  Attach an account to the request
//                 [request setAccount:[twitterAccounts lastObject]];
//                 
//                 //  Step 3:  Execute the request
//                 [request performRequestWithHandler:^(NSData *responseData,
//                                                      NSHTTPURLResponse *urlResponse,
//                                                      NSError *error) {
//                     if (responseData) {
//                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
//                             NSError *jsonError;
//                             NSDictionary *timelineData =
//                             [NSJSONSerialization
//                              JSONObjectWithData:responseData
//                              options:NSJSONReadingAllowFragments error:&jsonError];
//                             
//                             if (timelineData) {
//                                 NSLog(@"Timeline Response: %@\n", timelineData);
//                             }
//                             else {
//                                 // Our JSON deserialization went awry
//                                 NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
//                             }
//                         }
//                         else {
//                             // The server did not respond successfully... were we rate-limited?
//                             NSLog(@"The response status code is %d", urlResponse.statusCode);
//                         }
//                     }
//                 }];
//             }
//             else {
//                 // Access was not granted, or an error occurred
//                 NSLog(@"%@", [error localizedDescription]);
//             }
//         }];
//    }
//}




//{
//    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"screen_name",nil];
//    
//    ACAccountStore *account = [[ACAccountStore alloc] init];
//    ACAccountType *twitterAccountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    NSArray *twitterAccounts = [account accountsWithAccountType:twitterAccountType];
//    
//    // Runing on iOS 6
//    if (NSClassFromString(@"SLComposeViewController") && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//    {
//        [account requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error)
//         {
//             if (granted)
//             {
//                 
//                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url                                      parameters:params];
//                 
//                 [request setAccount:[twitterAccounts lastObject]];
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^
//                                {
//                                    
//                                    [NSURLConnection sendAsynchronousRequest:request.preparedURLRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response1, NSData *data, NSError *error)
//                                     {
//                                         dispatch_async(dispatch_get_main_queue(), ^
//                                                        {
//                                                            if (data)
//                                                            {
//                                                                //                                                                [self loadData:data];
//                                                                
//                                                                NSString* newStr = [[NSString alloc] initWithData:data
//                                                                                                         encoding:NSUTF8StringEncoding];
//                                                                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
//                                                                
//                                                                
//                                                                NSLog(@"data:%@",newStr);
//                                                            }
//                                                        });
//                                     }];
//                                });
//             }
//         }];
//    }
//    else if (NSClassFromString(@"TWTweetComposeViewController") && [TWTweetComposeViewController canSendTweet]) // Runing on iOS 5
//    {
//        [account requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error)
//         {
//             if (granted)
//             {
//                 TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
//                 [request setAccount:[twitterAccounts lastObject]];
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^
//                                {
//                                    [NSURLConnection sendAsynchronousRequest:request.signedURLRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response1, NSData *data, NSError *error)
//                                     {
//                                         dispatch_async(dispatch_get_main_queue(), ^
//                                                        {
//                                                            if (data)
//                                                            {
//                                                                NSString* newStr = [[NSString alloc] initWithData:data
//                                                                                                         encoding:NSUTF8StringEncoding];
//                                                                
//                                                                
//                                                                NSLog(@"data:%@",newStr);                                                           }
//                                                        });
//                                     }];
//                                    
//                                    
//                                });
//             }
//         }];
//    }
//}






-(void)setupUIForLoginVC{
    self.slideUnlockView.layer.cornerRadius = 30.0f;
    self.imgUserLogin.layer.cornerRadius = 25.0f;
    self.imgUserLogin.layer.masksToBounds=YES;
    self.imgUserLogin.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.imgUserLogin.layer.shadowOffset = CGSizeMake(1.0, 2.0);
   self.imgUserLogin.layer.shadowOpacity = 1.0;

}

-(void)moveImage:(UIPanGestureRecognizer*)panGues{
    CGPoint point = [panGues locationInView:self.slideUnlockView];//get the coordinate
    if(point.x >= kUserMinOrigin && point.x <=kUserMaxOrigin)
    {
        CGRect frame = self.imgUserLogin.frame;
        frame.origin.x=point.x-(self.imgUserLogin.frame.size.width/2);
        self.imgUserLogin.frame = frame;
        if(point.x > kUserLoginAcceptDrag){
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [self loginUser];
            });
        }
    }
    if(panGues.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.imgUserLogin.frame;
            frame.origin.x=kUserMinOrigin;
            self.imgUserLogin.frame=frame;
        }];
    }
}

-(void)loginUser{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    if(!defaultAccountFound){
        [self performSegueWithIdentifier:@"gotoLoginView" sender:nil];
        return;
    }
    
    NSString* loggedInUserEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUserEmail"];
    
    
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    NSString *resultString = [[loggedInUserEmail componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"."];
    NSLog (@"Result: %@", resultString);
    
    NSString* chatUserName = resultString;
    
    
    
    NSString* loggedInUserPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUserPassword"];
    if(!loggedInUserEmail){
        [[AccessContactVC sharedManager] requestFacebookAccessFirstTime];
    }
    else if(loggedInUserEmail && !loggedInUserPassword){
        [[AccessContactVC sharedManager] setUserFBEmail:loggedInUserEmail];
        [self performSegueWithIdentifier:@"gotoLoginView" sender:nil];
    }
    else
        [self performSegueWithIdentifier:@"gotoTabBarController" sender:nil];
    [[ChatSharedManager sharedManager] setTxtUserName:chatUserName];
    [[ChatSharedManager sharedManager] setTxtUserPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"loggedInUserPassword"]];
    [[ChatSharedManager sharedManager] loginChatFunction:@"LOGIN"];
}

-(void)accessedUserFBAccountSuccessfully:(BOOL)success{
    if(success){
        self.verfiedUserView.hidden=NO;
        [hud hide:YES];
        
        NSString* usrProfImagePath = @"~/Documents/userFBImage.png";
        UIImage* tempImage = [UIImage imageWithContentsOfFile:[usrProfImagePath stringByExpandingTildeInPath]];
        self.imgUserLogin.image = tempImage;
        defaultAccountFound= YES;
    }
    else{
        [hud hide:YES];
         self.verfiedUserView.hidden=NO;
        defaultAccountFound= NO;
//        UIAlertView* fetchPhoneBK = [[UIAlertView alloc] initWithTitle:@"Account" message:@"No Default Account was found on this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [fetchPhoneBK show];
        [self signUpUser];
    }
}

-(void)signUpUser{
    NSLog(@"Sign Up User");
    [self performSegueWithIdentifier:@"gotoLoginView" sender:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
