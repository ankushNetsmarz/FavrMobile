//
//  LoginScreenVC.h
//  Favr
//
//  Created by Taranjit Singh on 27/05/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface LoginScreenVC : UIViewController <UIGestureRecognizerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIScrollView *mailViewScroll;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailId;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) NSString *txtUserName;
@property (weak, nonatomic) IBOutlet UIImageView* userFBPic;


@end
