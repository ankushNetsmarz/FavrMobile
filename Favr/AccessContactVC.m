        //
//  AccessContactVC.m
//  Favr
//
//  Created by Taranjit Singh on 03/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

//@import AddressBook;
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AccessContactVC.h"
#import "ContactsData.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface AccessContactVC ()
{
    BOOL isFacebookAvailable;
}
@property(nonatomic,strong)ACAccountStore* accountStore;
@property (strong, nonatomic)ACAccount *facebookAccount;
@property NSString * addressBookNum;

@end

@implementation AccessContactVC

+(id)sharedManager{
    static AccessContactVC *sharedManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AccessContactVC alloc] init];
    });
    return sharedManager;
}

-(void)fetchContacts{
  //  [self getContacts];
   self.userContacts = [AccessContactVC getAllContacts];
   #warning Remove below code in production
    NSLog(@"Contact retrieved %d",self.userContacts.count);
    int maxCount = self.userContacts.count > 5 ? 5 : self.userContacts.count;
    if(self.userContacts.count > 0){
        for(int i=0;i<maxCount;i++){
            NSLog(@"User Contact = %@",((ContactsData*)[self.userContacts objectAtIndex:i]).emails);
        }
    }
}



+(NSArray *)getAllContacts
{
    
    CFErrorRef *error = nil;
    
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
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
                
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
            
            
            
            [items addObject:contacts];
            
#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif
            
            
            
            
        }
        return items;
        
        
        
    } else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
        return NO;
        
        
    }
    
}

-(void)getContacts{
    if ([self isABAddressBookCreateWithOptionsAvailable]) {
        CFErrorRef error = nil; // no asterisk
        ABAddressBookRef addressBook =
        ABAddressBookCreateWithOptions(NULL, &error); // indirection
        if (!addressBook) // test the result, not the error
        {
            NSLog(@"ERROR!!!");
            return; // bail
        }
        CFArrayRef arrayOfPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSLog(@"%@", arrayOfPeople); // let's see how we did}
    }
}
-(BOOL)isABAddressBookCreateWithOptionsAvailable {
    return &ABAddressBookCreateWithOptions != NULL;
}

#pragma mark - FACEBOOK API CALLS
- (IBAction)requestUserInfo:(id)sender
{
    // We will request the user's public picture and the user's birthday
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"public_profile", @"read_friendlists",@"user_friends",@"email"];
    
    // Request the permissions the user currently has

    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSLog(@"Available Permissions = %@",result);
                                  // These are the current permissions the user has
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  
                                  // We will store here the missing permissions that we will have to request
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession
                                       requestNewReadPermissions:requestPermissions
                                       completionHandler:^(FBSession *session, NSError *error) {
                                           if (!error) {
                                               // Permission granted, we can request the user information
                                               [self makeRequestForUserData];
                                           } else {
                                               // An error occurred, we need to handle the error
                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                               NSLog(@"error %@", error.description);
                                           }
                                       }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestForUserData];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    
    
    
}

- (void) makeRequestForUserData
{
    NSString* searchTxt =@"me/friends";
   
    [FBRequestConnection startWithGraphPath:searchTxt
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSLog(@"user friends: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    
}

-(void)inviteNonFriends{
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"YOUR_MESSAGE_HERE"
     title:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSLog(@"[resultURL query] = %@",[resultURL query]);
           /*      if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
            */
            }
         }
     }];
 /*
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     
                                     // Optional parameter for sending request directly to user
                                     // with UID. If not specified, the MFS will be invoked
                                     @"", @"to",
                                     
                                     // Give the structured request information
                                     @"send", @"action_type",
                                     @"YOUR_OBJECT_ID", @"object_id",
                                     nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Take this bomb to blast your way to victory!"
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {}
     ];
*/
  }


- (void)requestFacebookAccessFirstTime {
    if(!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *facebookAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    /*
     When requesting access to the account is when the user will be prompted for consent.
     */
    NSDictionary *options = @{ ACFacebookAppIdKey: @"594680290562724",
                               ACFacebookPermissionsKey: @[@"email",@"user_about_me"],
                               ACFacebookAudienceKey: ACFacebookAudienceFriends };
    [self.accountStore requestAccessToAccountsWithType:facebookAccount options:options completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error = %@", error);
            if(error){
                [self.delegate accessedUserFBAccountSuccessfully:NO];
            }
            if(granted){
                NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccount];
                //it will always be the last object with single sign on
                ACAccount* fbAccount = [accounts lastObject];
                ACAccountCredential *fbCredential = [fbAccount credential];
                 self.fbAccessToken = [fbCredential oauthToken];
                NSLog(@"Facebook Access Token: %@", self.fbAccessToken);
                
                [self getMyInfo:fbAccount];
            }
        });
    }];
}



-(void)getMyInfo:(ACAccount*)facebookAccount
{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        
        if(!error)
        {
            
            NSDictionary *list =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSLog(@"Dictionary contains: %@", list );
            
            [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"facebookProfileInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            self.userFBEmail = [NSString stringWithFormat:@"%@",[list objectForKey:@"email"]];
            NSLog(@"global mail ID : %@",self.userFBEmail);
           [[NSUserDefaults standardUserDefaults] setObject:self.userFBEmail forKey:@"loggedInUserEmail"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            self.userFBName = [NSString stringWithFormat:@"%@",[list objectForKey:@"name"]];
            NSLog(@"facebook name %@",self.userFBName);
            
            self.userFBID = [NSString stringWithFormat:@"%@",[list objectForKey:@"id"]];
            [self getUserFBDisplayPhoto:facebookAccount];

        }
        else
        {
            //handle error gracefully
            NSLog(@"error from get%@",error);
            //attempt to revalidate credentials
            [self.delegate accessedUserFBAccountSuccessfully:NO];
        }
        
    }];
    
}

-(void)getUserFBDisplayPhoto:(ACAccount*)facebookAccount{
[self callAnotherMethod];
    return;
    
    NSString* url= [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",self.userFBID];
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userFBImage = [UIImage imageWithData:data];
            });
           //[self.delegate accessedUserFBAccountSuccessfully:YES];

        }
        else{
            NSLog(@"Error =  %@",error);
        }
    }];
    
    
    
}

-(void)callAnotherMethod{

    NSString* str = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=0&type=normal&key=594680290562724&access_token=%@",self.userFBID,self.fbAccessToken];
    NSLog(@"NEW STR ========> %@",str);
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data, NSError *connectionError)
         {
             if (data.length > 0 && connectionError == nil)
             {
                 NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:NULL];
                 NSLog(@"FB = %@",greeting);
                 
                 NSURL* imgUrl =  [NSURL URLWithString:[[greeting objectForKey:@"data"] objectForKey:@"url"]];
                 [self performSelectorInBackground:@selector(downlaodAndSaveUserProfImage:) withObject:imgUrl];
             /*
                 
                 dispatch_queue_t imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
                 
                 dispatch_async(imageQueue, ^{
                    
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIImage* image = [UIImage imageWithData:data];
                         self.userFBImage= [UIImage imageWithData:data];
                     });
                     
                 });
              */
             }
         }];
}

-(void)downlaodAndSaveUserProfImage:(NSURL*)imgUrl{
    NSData *data = [NSData dataWithContentsOfURL:imgUrl];
    NSString* usrProfImagePath = @"~/Documents/userFBImage.png";
    [data writeToFile:[usrProfImagePath stringByExpandingTildeInPath] atomically:YES];
    [self.delegate accessedUserFBAccountSuccessfully:YES];
}
@end
