//
//  CreateFavrVC.h
//  Favr
//
//  Created by Ankush on 30/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickContactVC.h"
#import "QuidProQuoVC.h"

@interface CreateFavrVC : UIViewController  <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTxtFld;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UITextView *descTxtVew;

@property (strong, nonatomic) IBOutlet UIButton *asapBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *NLTBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *AYECBtnObj;

@property (strong, nonatomic) IBOutlet UIButton *anonymousBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *ATFBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *ANTFBtnObj;

- (IBAction)whenBtnAct:(UIButton *)sender;

- (IBAction)privicyBtnAct:(UIButton *)sender;

- (IBAction)backButtonAct:(UIBarButtonItem *)sender;
- (IBAction)pickContactBtnAct:(UIBarButtonItem *)sender;
- (IBAction)datePickerAct:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *datePickerObj;

@end
