//
//  AppDelegate.m
//  Favr
//
//  Created by Weexcel on 28/04/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <Parse/Parse.h>
#import "AccessContactVC.h"

#import "LeftSlideMenuVC.h"
#import "RightSlideMenuVC.h"
#import "SlideNavigationController.h"
#import "Quickblox/Quickblox.h"

@implementation AppDelegate
@synthesize groupSelected;
@synthesize loginSignupFlag;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [QBSettings setApplicationID:11524];
    [QBSettings setAuthorizationKey:@"AFwuBUxEB3UvWZJ"];
    [QBSettings setAuthorizationSecret:@"8ZVFkrcbYZwHAVA"];
    [QBSettings setAccountKey:@"P9ZsMADae6SyxxkRTTxa"];
    
    
    [Parse setApplicationId:@"FAErcgGLrgrlSokwv5UTugwVkrIzNQGbrtvTInTV"
                  clientKey:@"2hMlmafpYE3kiLVxurYBaTHQ6StngudjXYMxcUgZ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"mainStoryboard"
															 bundle: nil];
	
	LeftSlideMenuVC *leftMenu = (LeftSlideMenuVC*)[mainStoryboard
                                                   instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
	
	RightSlideMenuVC *rightMenu = (RightSlideMenuVC*)[mainStoryboard
                                                      instantiateViewControllerWithIdentifier: @"RightMenuViewController"];
	
	[SlideNavigationController sharedInstance].rightMenu = rightMenu;
	[SlideNavigationController sharedInstance].leftMenu = leftMenu;


   return YES;
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"URL = %@", url);
    NSString* string = [NSString stringWithFormat:@"%@",url];
    if([string hasPrefix:@"com.netsmartz.favr.favr:/oauth2callback?"]){
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }

    else{
        // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        // You can add your app-specific url handling code here if needed
        return wasHandled;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
