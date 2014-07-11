//
//  QuidProQuoVC.h
//  Favr
//
//  Created by Ankush on 11/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickContactVC.h"

@interface QuidProQuoVC : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    NSString *favrTitleStr, *favrDescStr;
}
@property (strong, nonatomic) IBOutlet UITextField *quidProTitle;
@property (strong, nonatomic) IBOutlet UITextView *quidProDesc;

@property (strong, nonatomic) NSString *favrTitleString;
@property (strong, nonatomic) NSString *favrDescriptionString;

- (IBAction)backBtnAct:(UIBarButtonItem *)sender;
- (IBAction)nextBtnAction:(UIBarButtonItem *)sender;

@end
