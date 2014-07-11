//
//  ContactUserDetailVC.h
//  Favr
//
//  Created by Ankush on 27/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ContactUserDetailVC : UIViewController
{
    MBProgressHUD *hud;
    NSArray *userDetails;
}
@property (nonatomic, retain) NSString *userId;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;

@property (strong, nonatomic) IBOutlet UILabel *userFullName;

@property (strong, nonatomic) IBOutlet UIImageView *acceptedImageView;
@property (strong, nonatomic) IBOutlet UIButton *acceptedBtnObj;

@property (strong, nonatomic) IBOutlet UILabel *userFullNameHis;

@property (strong, nonatomic) IBOutlet UIImageView *acceptedFavrImageView;
@property (strong, nonatomic) IBOutlet UIButton *acceptedFavrBtnObj;

@property (strong, nonatomic) IBOutlet UIImageView *askedFavrImageView;
@property (strong, nonatomic) IBOutlet UIButton *askedFavrBtnObj;

@property (strong, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (strong, nonatomic) IBOutlet UIButton *fbBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *twitterBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *gPlusBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *linkedInBtnObj;

- (IBAction)backButtonAct:(UIBarButtonItem *)sender;

- (IBAction)socialSharingBtnAct:(UIButton *)sender;


@end
