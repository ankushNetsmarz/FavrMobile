//
//  ViewController.m
//  GPlusSelfTut
//
//  Created by Taranjit Singh on 07/06/14.
//  Copyright (c) 2014 Taranjit Singh. All rights reserved.
//

#import "SocialSyncVC.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "ShareConfiguration.h"
#import "AccessContactVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface SocialSyncVC ()
@property (nonatomic, strong) OAuthLoginView *oAuthLoginView;
@property (nonatomic)NSMutableArray *connections;
@property (nonatomic)NSDictionary *connectionDictionary;
@property (nonatomic)NSString *twitterUsername;
@end

@implementation SocialSyncVC
static NSString * const kClientId = @"568503989663-c8pb9qtnd09cf8o7ohs1ugmnko16ocpt.apps.googleusercontent.com";
static int const kFBSwitch = 1;
static int const kGPPBSwitch = 2;
static int const kTwitterSwitch = 3;
static int const kLinkedInSwitch = 4;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.connections = [[NSMutableArray alloc]init];
    [ShareConfiguration sharedInstance].useNativeSharebox=YES;
    [ShareConfiguration sharedInstance].sharePrefillText=@"Hi Bro, Just Testing.. :)";
    [ShareConfiguration sharedInstance].shareURL=@"www.WeExcel.com";
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    [self.signInButton setStyle:kGPPSignInButtonStyleIconOnly];
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    [signIn trySilentAuthentication];
    [self initiateScrollView];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.socialSharingView.bounds];
    self.socialSharingView.layer.masksToBounds = NO;
    self.socialSharingView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.socialSharingView.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    self.socialSharingView.layer.shadowOpacity = 0.15f;
    self.socialSharingView.layer.shadowPath = shadowPath.CGPath;
    
    
}


-(void)initiateScrollView{
    NSInteger numberOfViews = 3;
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.view.frame.size.width+40;
        UIImageView *demoImage = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 240, 240)];
        demoImage.image = [UIImage imageNamed:@"1024x1024_blue_logo_with_text.png"];
        [self.mainScrollView addSubview:demoImage];

    }
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width * numberOfViews, 200);
    self.mainScrollView.delegate=self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.mainScrollView.isDragging || self.mainScrollView.isDecelerating){
        self.pageControl.currentPage = lround(self.mainScrollView.contentOffset.x / (self.mainScrollView.contentSize.width / self.pageControl.numberOfPages));
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)socialSwitchesActivation:(UISwitch*)sender{
    if (sender.on) {
        switch (sender.tag) {
            case kFBSwitch:
            {
                NSLog(@"facebook profile info %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookProfileInfo"]);
                fbProfileDetailsDict = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookProfileInfo"]];
                NSLog(@"date of birth %@", [fbProfileDetailsDict objectForKey:@"birthday"]);
                NSString *nameString = [NSString stringWithFormat:@"%@ %@", [fbProfileDetailsDict objectForKey:@"first_name"], [fbProfileDetailsDict objectForKey:@"last_name"]];
                NSLog(@"Name %@ %@", [fbProfileDetailsDict objectForKey:@"first_name"], [fbProfileDetailsDict objectForKey:@"last_name"]);
                NSLog(@"email %@", [fbProfileDetailsDict objectForKey:@"email"]);
                NSLog(@"work at %@", [[[[fbProfileDetailsDict objectForKey:@"work"] objectAtIndex:1] objectForKey:@"employer"] objectForKey:@"name"]);
                NSLog(@"Home town %@", [[fbProfileDetailsDict objectForKey:@"hometown"] objectForKey:@"name"]);
                fbInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:nameString, @"name",[fbProfileDetailsDict objectForKey:@"birthday"], @"Date_Of_Birth", [[fbProfileDetailsDict objectForKey:@"hometown"] objectForKey:@"name"], @"Home_Town", [fbProfileDetailsDict objectForKey:@"email"], @"Email_Id", [[[[fbProfileDetailsDict objectForKey:@"work"] objectAtIndex:1] objectForKey:@"employer"] objectForKey:@"name"], @"Work_At",  nil];
                userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
                
                //                [self fetchFBFriends:nil];
                
                [PFCloud callFunctionInBackground:@"addSocialDetail"
                                   withParameters:@{@"userId": userId,
                                                    @"facebookDetail": fbInfoDict,
                                                    @"gPlusDetail": @"",
                                                    @"twitterDetail": @"",
                                                    @"linkedInDetail": @""
                                                    }
                                            block:^(NSString *results, NSError *error) {
                                                if (!error) {
                                                    NSLog(@"result: %@",results);
                                                    
//                                                    if([results isEqualToString:@"You are not registered with us, try SignUp!"])
//                                                    {
//                                                        //                                                        [hud hide:YES];
//                                                        //                                                        [self showAlertWithText:@"Favr" :results];
//                                                    }
//                                                    else if([results isEqualToString:@"Username/Password doesnt match !"])
//                                                    {
//                                                        //                                                        [hud hide:YES];
//                                                        //                                                        [self showAlertWithText:@"Favr" :results];
//                                                    }
//                                                    else{
//                                                        //                                                        [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
//                                                        //                                                        [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
//                                                        //                                                        [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
//                                                        //                                                        [[NSUserDefaults standardUserDefaults]synchronize];
//                                                        //                                                        [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
//                                                        
//                                                    }
                                                    
                                                    
                                                    
                                                    
                                                }
                                            }];
            }
                
                break;
            case kGPPBSwitch:
                
                break;
            case kTwitterSwitch:
                [self initializeTwitter];
                break;
            case kLinkedInSwitch:
                [self activateLinkedInProfile];
                break;
            default:
                break;
        }
    }
}



#pragma mark FACEBOOK API

-(IBAction)fetchFBFriends:(id)sender{
    [[AccessContactVC sharedManager] inviteNonFriends];
}


/*
-(void)get
{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        
        if(!error)
        {
            
            NSDictionary *list =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSLog(@"Dictionary contains: %@", list );
            
            fbID = [NSString stringWithFormat:@"%@", [list objectForKey:@"id"]];
            globalFBID = fbID;
            
            gender = [NSString stringWithFormat:@"%@", [list objectForKey:@"gender"]];
            playerGender = [NSString stringWithFormat:@"%@", gender];
            NSLog(@"Gender : %@", playerGender);
            
            
            self.globalmailID   = [NSString stringWithFormat:@"%@",[list objectForKey:@"email"]];
            NSLog(@"global mail ID : %@",globalmailID);
            
            fbname = [NSString stringWithFormat:@"%@",[list objectForKey:@"name"]];
            NSLog(@"faceboooookkkk name %@",fbname);
            
            if([list objectForKey:@"error"]!=nil)
            {
                [self attemptRenewCredentials];
            }
            dispatch_async(dispatch_get_main_queue(),^{
                
            });
        }
        else
        {
            //handle error gracefully
            NSLog(@"error from get%@",error);
            //attempt to revalidate credentials
        }
        
    }];
    
    self.accountStore = [[ACAccountStore alloc]init];
    ACAccountType *FBaccountType= [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSString *key = @"451805654875339";
    NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:key,ACFacebookAppIdKey,@[@"friends_videos"],ACFacebookPermissionsKey, nil];
    
    
    [self.accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:
     ^(BOOL granted, NSError *e) {}];
    
}



-(void)getFBFriends
{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        
        if(!error)
        {
            
            NSDictionary *friendslist =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            for (id facebookFriendList in [friendslist objectForKey:@"data"])
            {
                NSDictionary *friendList = (NSDictionary *)facebookFriendList;
                [facebookFriendIDArray addObject:[friendList objectForKey:@"id"]];
            }
            
            
            if([friendslist objectForKey:@"error"]!=nil)
            {
                [self attemptRenewCredentials];
            }
            dispatch_async(dispatch_get_main_queue(),^{
                
            });
        }
        else
        {
            //handle error gracefully
            NSLog(@"error from get%@",error);
            //attempt to revalidate credentials
        }
        
    }];
    
    self.accountStore = [[ACAccountStore alloc]init];
    ACAccountType *FBaccountType= [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSString *key = @"451805654875339";
    NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:key,ACFacebookAppIdKey,@[@"friends_videos"],ACFacebookPermissionsKey, nil];
    
    
    [self.accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:
     ^(BOOL granted, NSError *e) {}];
    
}
*/


#pragma mark - LINKEDIN API CALLS

- (void)activateLinkedInProfile
{
    self.oAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:self.oAuthLoginView];
    
    [self presentViewController:self.oAuthLoginView animated:YES completion:nil];
}
-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // We're going to do these calls serially just for easy code reading.
    // They can be done asynchronously
    // Get the profile, then the network updates
    [self profileApiCall];
	
}


- (void)profileApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:self.oAuthLoginView.consumer
                                       token:self.oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(profileApiCallResult:didFinish:)
                  didFailSelector:@selector(profileApiCallResult:didFail:)];
}
- (void)profileApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *profile = [responseBody objectFromJSONString];
    
    if ( profile )
    {
        NSString * userName= [[NSString alloc] initWithFormat:@"%@ %@",
                              [profile objectForKey:@"firstName"], [profile objectForKey:@"lastName"]];
        NSLog(@"User Name %@",userName);
    }
    
    // The next thing we want to do is call the network updates
    [self GetConnectionsCall];
    [self networkApiCall];
    
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

-(void)GetConnectionsCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,email-address)"];
    
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:self.oAuthLoginView.consumer
                                       token:self.oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(connectionsApiCallResult:didFinish:)
                  didFailSelector:@selector(connectionsApiCallResult:didFail:)];
    
}
- (void)connectionsApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    NSLog(@"connectionsApiCallResult====%@",responseBody);
    
    self.connectionDictionary = [responseBody objectFromJSONString];
    
//    for(int i=0;i<[[self.connectionDictionary objectForKey:@"_total"]intValue];i++)
//    {
//        
//        NSDictionary *person=  [[[self.connectionDictionary objectForKey:@"values"]objectAtIndex:i]objectForKey:@"firstName"];
//        [self.connections addObject:person];
//        NSLog(@"Connection %d : %@",i,person);
//        
//    }
    for(NSDictionary* person in [self.connectionDictionary objectForKey:@"values"]){
        [self.connections addObject:person];
    }
    NSLog(@"%@",self.connections);

}

- (void)connectionsApiCallResult:(OAServiceTicket *)ticket didFail:(NSError *)error
{
    NSLog(@"%@",[error description]);
}


- (void)networkApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/network/updates?scope=self&count=1&type=STAT"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:self.oAuthLoginView.consumer
                                       token:self.oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(networkApiCallResult:didFinish:)
                  didFailSelector:@selector(networkApiCallResult:didFail:)];
    
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *person = [[[[[responseBody objectFromJSONString]
                               objectForKey:@"values"]
                              objectAtIndex:0]
                             objectForKey:@"updateContent"]
                            objectForKey:@"person"];
    
    
    if ( [person objectForKey:@"currentStatus"] )
    {
        
       NSLog(@"Person Status %@",[person objectForKey:@"currentStatus"]);
    }
    else
    {
        
        NSString* tempStr = [[[[person objectForKey:@"personActivities"]
                              objectForKey:@"values"]
                             objectAtIndex:0]
                            objectForKey:@"body"];
        NSLog(@"LinkedIn personActivities = %@",tempStr);
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}


#pragma mark - GOOGLE API

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        self.signInButton.hidden = YES;
        [self.switchGoogleP setOn:YES animated:YES];
        // Perform other actions here, such as showing a sign-out button
    } else {
        self.signInButton.hidden = NO;
        [self.switchGoogleP setOn:NO animated:YES];
        // Perform other actions here
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

-(IBAction)inviteGooglePlusPeople:(id)sender{
    ListPeopleViewController *peoplePicker =
    [[ListPeopleViewController alloc] initWithNibName:nil bundle:nil];
    peoplePicker.allowSelection = YES;
    peoplePicker.delegate = self;
    peoplePicker.navigationItem.title = @"Pick people";
    [self presentViewController:peoplePicker animated:YES completion:nil];
    
    
}
- (IBAction)shareButton:(id)sender {
    id<GPPShareBuilder> shareBuilder = [self shareBuilder];
    if (![shareBuilder open]) {
        NSLog(@"Status: Error (see console).");
    }
}
- (id<GPPShareBuilder>)shareBuilder {
    // End editing to make sure all changes are saved to [ShareConfiguration sharedInstance].
    [self.view endEditing:YES];
    
    // Create the share builder instance.
    id<GPPShareBuilder> shareBuilder = [ShareConfiguration sharedInstance].useNativeSharebox ?
    [[GPPShare sharedInstance] nativeShareDialog] :
    [[GPPShare sharedInstance] shareDialog];
    
    if ([ShareConfiguration sharedInstance].urlEnabled) {
        NSString *inputURL = [ShareConfiguration sharedInstance].shareURL;
        NSURL *urlToShare = [inputURL length] ? [NSURL URLWithString:inputURL] : nil;
        if (urlToShare) {
            [shareBuilder setURLToShare:urlToShare];
        }
    }
    
    // Add deep link content.
    if ([ShareConfiguration sharedInstance].deepLinkEnabled) {
        [shareBuilder setContentDeepLinkID:[ShareConfiguration sharedInstance].contentDeepLinkID];
        NSString *title = [ShareConfiguration sharedInstance].contentDeepLinkTitle;
        NSString *description = [ShareConfiguration sharedInstance].contentDeepLinkDescription;
        NSString *urlString = [ShareConfiguration sharedInstance].contentDeepLinkThumbnailURL;
        NSURL *thumbnailURL = urlString.length ? [NSURL URLWithString:urlString] : nil;
        [shareBuilder setTitle:title description:description thumbnailURL:thumbnailURL];
    }
    
    NSString *inputText = [ShareConfiguration sharedInstance].sharePrefillText;
    NSString *text = [inputText length] ? inputText : nil;
    if (text) {
        [shareBuilder setPrefillText:text];
    }
    
    
    // Attach media if we are using the native sharebox and have selected a media element.,
    if ([ShareConfiguration sharedInstance].useNativeSharebox) {
        if ([ShareConfiguration sharedInstance].mediaAttachmentEnabled) {
            if ([ShareConfiguration sharedInstance].attachmentImage) {
                [(id<GPPNativeShareBuilder>)shareBuilder attachImage:[ShareConfiguration sharedInstance].attachmentImage];
            } else if ([ShareConfiguration sharedInstance].attachmentVideoURL) {
                [(id<GPPNativeShareBuilder>)shareBuilder attachVideoURL:
                 [ShareConfiguration sharedInstance].attachmentVideoURL];
            }
        }
        if ([ShareConfiguration sharedInstance].sharePrefillPeople.count) {
            [(id<GPPNativeShareBuilder>)shareBuilder
             setPreselectedPeopleIDs:[ShareConfiguration sharedInstance].sharePrefillPeople];
        }
    }
    
    return shareBuilder;
}

#pragma mark - ListPeopleViewControllerDelegate

- (void)viewController:(ListPeopleViewController *)viewController didPickPeople:(NSArray *)people {
    [ShareConfiguration sharedInstance].sharePrefillPeople = people;
    [self performSelector:@selector(shareButton:) withObject:nil afterDelay:1.0];
    
}


#pragma mark - TWITTER API

- (void)initializeTwitter
{
    // Request access to the Twitter accounts
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
//                NSLog(@"twitter username %@", [twitterAccount ])
                // Creating a request to get the info about a user on Twitter
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"]];
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
//                            NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
//                            
//                            int followers = [[(NSDictionary *)TWData objectForKey:@"followers_count"] integerValue];
                            int following = [[(NSDictionary *)TWData objectForKey:@"friends_count"] integerValue];
//                            int tweets = [[(NSDictionary *)TWData objectForKey:@"statuses_count"] integerValue];
                            
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            
                            
                            // Update the interface with the loaded data
                            
                            
                            NSLog(@"Twitter Screen_name = %@",[NSString stringWithFormat:@"@%@",screen_name]);
                            
                            NSLog(@"Twitter Followings = %@",[NSString stringWithFormat:@"%i", following]);
                            
                            NSLog(@"Twitter Followers = %@",[[(NSDictionary *)TWData objectForKey:@"status"] objectForKey:@"text"]);
                            
                            // Get the profile image in the original resolution
                            
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            [self getProfileImageForURLString:profileImageStringURL];
                            
                            
                            // Get the banner image, if the user has one
                            
                            if (bannerImageStringURL) {
                                NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
                                [self getBannerImageForURLString:bannerURLString];
                            }
                        }
                    });
                }];
            }
            else
            {
                NSLog(@"Please configure account in setting");
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (void) getProfileImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
//    NSData *data = [NSData dataWithContentsOfURL:url];

}

- (void) getBannerImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
//    NSData *data = [NSData dataWithContentsOfURL:url];

}
@end
