//
//  SettingVC.h
//  Favr
//
//  Created by Ankush on 24/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutVC.h"
#import "InviteAFriendVC.h"
#import "SocialMediaVC.h"
#import "GroupNameAndDetailVC.h"
#import "SettingVCCell.h"

@interface SettingVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *settingArray;
    NSArray *settingImageArray;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
