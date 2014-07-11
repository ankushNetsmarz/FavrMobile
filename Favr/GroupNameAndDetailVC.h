//
//  GroupNameAndDetailVC.h
//  Favr
//
//  Created by Ankush on 04/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Parse/Parse.h"

@interface GroupNameAndDetailVC : UIViewController <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    MBProgressHUD *hud;
    CGRect rectGroup;
}
@property (strong, nonatomic) IBOutlet UIButton *groupImageBtnObj;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageViewObj;
@property (strong, nonatomic) IBOutlet UITextField *groupTitleTxtFld;
@property (strong, nonatomic) IBOutlet UITextView *GroupDescTxtView;
@property (nonatomic, retain) NSMutableArray *groupMemberArray;

@property (strong, nonatomic) IBOutlet UIView *groupInfoView;


- (IBAction)createGroup:(UIBarButtonItem *)sender;
- (IBAction)groupImageBtnAct:(UIButton *)sender;
- (IBAction)backBtnAct:(UIBarButtonItem *)sender;

@end
