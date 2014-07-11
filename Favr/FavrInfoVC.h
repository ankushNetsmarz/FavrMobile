//
//  FavrInfoVC.h
//  Favr
//
//  Created by Ankush on 03/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "MBProgressHUD.h"
@interface FavrInfoVC : UIViewController
{
    MBProgressHUD *hud;
    NSArray *favrInfoArray;
}
@property (nonatomic, assign) int pendingFavrStatus;
@property (nonatomic, retain) NSString *incoming_outgoingString;
@property (nonatomic, retain) NSString *favrId;
@property (strong, nonatomic) IBOutlet UILabel *favrTitleLbl;
@property (strong, nonatomic) NSString *navigationTitle;

@property (strong, nonatomic) IBOutlet UILabel *favrDescLabel;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)backBtnAct:(UIBarButtonItem *)sender;
- (IBAction)FavrRejectedBtnAct:(UIButton *)sender;
- (IBAction)favrAcceptedBtnAct:(UIButton *)sender;
- (IBAction)favrChatBtnAct:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *favrAcceptBtnObj;
@property (strong, nonatomic) IBOutlet UIButton *favrRejectButtonObj;

@end
