//
//  QuidProQuoVC.m
//  Favr
//
//  Created by Ankush on 11/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "QuidProQuoVC.h"

@interface QuidProQuoVC ()

@end

@implementation QuidProQuoVC

@synthesize favrTitleString, favrDescriptionString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.quidProDesc.delegate = self;
    self.quidProTitle.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}


- (IBAction)backBtnAct:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextBtnAction:(UIBarButtonItem *)sender {
    PickContactVC *pickContactVC = [[PickContactVC alloc] init];
    pickContactVC.favrTitleString = favrTitleString;
    pickContactVC.favrDescriptionString = favrDescriptionString;
    [self.navigationController pushViewController:pickContactVC animated:YES];
}
@end
