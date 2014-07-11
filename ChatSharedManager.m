//
//  ViewController.m
//  ChatAppSelfTut
//
//  Created by Taranjit on 24/06/14.
//  Copyright (c) 2014 Taranjit. All rights reserved.
//

#import "ChatSharedManager.h"
//#import "СhatViewController.h"
#import "ChatService.h"
#import "Quickblox/Quickblox.h"
#import "LocalStorageService.h"

@interface ChatSharedManager ()
{
    int selectedIndex;
}
@property (nonatomic, strong) UsersPaginator *paginator;
@property (nonatomic, strong) QBUUserLogInResult *res;

@end

@implementation ChatSharedManager

+(id)sharedManager{
    static ChatSharedManager *sharedManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ChatSharedManager alloc] init];
    });
    return sharedManager;
}



- (void)initializeChatInstance{
    
    [QBAuth createSessionWithDelegate:self];
    
    // Do any additional setup after loading the view, typically from a nib.
    QBUUserLogInResult *res = (QBUUserLogInResult*)[[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_USER"];
    if(res)
    {
        NSLog(@"USer Already Login");
    }
    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];
    self.chatUsers = [[NSMutableArray alloc]init];
    
    
}

-(void)checkForLoggedInUser{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:@"CURRENT_USER"];
    if (savedArray != nil)
    {
        QBUUser* user  = (QBUUser*)[NSKeyedUnarchiver unarchiveObjectWithData:savedArray];
        if(user){
            [[LocalStorageService shared]setCurrentUser:user];
            NSLog(@"user = %@",user);
            [[ChatService instance] loginWithUser:[LocalStorageService shared].currentUser completionBlock:^{
                NSLog(@"aa geya wapas..Login _1");
                [self fetchUserListFromServer];
            }];
        }
        else{
            NSLog(@"NO user founD");
        }
    }
}




#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(result.success && [result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        NSLog(@"User Session Created");
        [self checkForLoggedInUser];
        
    }
    
    if(result.success && [result isKindOfClass:[QBUUserLogInResult class]]){
        NSLog(@"User Login Successful");
        self.res = (QBUUserLogInResult *)result;
        self.res.user.password = self.txtUserPassword;
         [[LocalStorageService shared] setCurrentUser: self.res.user];
         [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CURRENT_USER"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.res.user] forKey:@"CURRENT_USER"];
        
         [[ChatService instance] loginWithUser:[LocalStorageService shared].currentUser completionBlock:^{
             NSLog(@"aa geya wapas..Login block ch");
         }];

        [self fetchUserListFromServer];
        
    }
    
    if(result.success && [result isKindOfClass:[QBUUserResult class]]){
        self.res = (QBUUserLogInResult *)result;
        self.res.user.password = self.txtUserPassword;
        [[LocalStorageService shared] setCurrentUser: self.res.user];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CURRENT_USER"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.res.user] forKey:@"CURRENT_USER"];
        
        [[ChatService instance] loginWithUser:[LocalStorageService shared].currentUser completionBlock:^{
            NSLog(@"aa geya wapas..Login block ch");
        }];
        
        [self fetchUserListFromServer];
    }
}

- (void)refreshChatSession{
        [QBAuth createSessionWithDelegate:self];
}

-(void)fetchUserListFromServer{
    NSLog(@"Fetching User List From server");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.chatUsers removeAllObjects];
    [self.paginator fetchFirstPage];
    
}


- (void)loginChatFunction:(NSString*)login_Register{
    if([login_Register isEqual:@"LOGIN"]){
        [QBUsers logInWithUserLogin:self.txtUserName
                           password:self.txtUserPassword
                           delegate:self context:nil];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else{
        QBUUser *user = [QBUUser user];
        user.password = self.txtUserPassword;
        user.login = self.txtUserName;
        [QBUsers signUp:user delegate:self context:nil];
    }

}



#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results{
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.chatUsers removeAllObjects];
    [self.chatUsers addObjectsFromArray:results];

}



@end
