//
//  signUp.h
//  Favr
//
//  Created by Ankush on 10/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"


@interface signUp : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic)           NSString    *usrName;
@property (strong, nonatomic)           NSString    *usrEmail;
@property (strong, nonatomic)           NSString    *usrPasswd;
@property (strong, nonatomic)           UIImage     *profileImage;
@property (weak, nonatomic)             IBOutlet UITextField *txtFullName;
@property (weak, nonatomic)             IBOutlet UITextField *txtEmail;
@property (weak, nonatomic)             IBOutlet UITextField *txtPassword;
@property (strong, nonatomic)           IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic)           IBOutlet UIButton  *profileImageBtn;

@property (weak, nonatomic)             IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic)             IBOutlet UIScrollView *mainScrollView;
- (IBAction)profileImageAct:(UIButton *)sender;

@end
