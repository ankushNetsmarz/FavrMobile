//
//  AccountVC.h
//  Favr
//
//  Created by Ankush on 24/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountVCCell.h"

@interface AccountVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *reciprocationTitleEarned, *reciprocationTitleOwed ;
    NSArray *combinedTitleReciprocation ;
    NSArray *reciprocationStatusEarned, *reciprocationStatusOwed ;
    NSArray *combinedStatusReciprocation ;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView ;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar ;

@end
