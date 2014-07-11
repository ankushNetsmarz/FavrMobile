//
//  AppDelegate.h
//  Favr
//
//  Created by Weexcel on 28/04/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//
//   98  197  210


#define twitterApiKey               @"NbdqXUIrOyfs1F3ahNj5oqBoo"
#define twitterSecretKey            @"PjlvAOmpWRn4t5GctmTBVbKGG0G49tLLxB7xokvz4thR25EMho"


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) int groupSelected;
@property (assign, nonatomic) int loginSignupFlag;


@end
