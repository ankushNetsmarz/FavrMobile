//
//  ViewController.h
//  GPlusSelfTut
//
//  Created by Taranjit Singh on 07/06/14.
//  Copyright (c) 2014 Taranjit Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListPeopleViewController.h"
#import <GooglePlus/GooglePlus.h>
#import "OAuthLoginView.h"
#import "JSONKit.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"
#import "Parse/Parse.h"

@class GPPSignInButton;
@interface SocialSyncVC : UIViewController <GPPSignInDelegate,ListPeopleViewControllerDelegate,UIScrollViewDelegate>
{
    NSDictionary *fbProfileDetailsDict, *fbInfoDict;
    NSString *userId;
}
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property(weak,nonatomic)IBOutlet UIView* socialSharingView;
@property(weak,nonatomic)IBOutlet UISwitch* switchGoogleP;
-(IBAction)socialSwitchesActivation:(UISwitch*)sender;
@end
