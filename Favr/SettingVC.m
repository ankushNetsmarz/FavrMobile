//
//  SettingVC.m
//  Favr
//
//  Created by Ankush on 24/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "SettingVC.h"

@interface SettingVC ()

@end

@implementation SettingVC

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
    settingArray = [[NSArray alloc] initWithObjects:@"About", @"Invite a Friend", @"Social Media", @"Gift Cards", @"Payment", nil];
    
    settingImageArray = [[NSArray alloc] initWithObjects: @"information-icon.png",  @"select-plus-icon.png", @"social-media-icon.png", @"gift-icon.png", @"cash-icon.png", nil];
    
    self.navigationController.navigationBar.barTintColor = [ UIColor colorWithRed:98.0/255.0 green:197.0/255.0 blue:210.0/255.0 alpha:1];
    
//    self.navigationBar.backgroundColor = [ UIColor colorWithRed:98.0/255.0 green:197.0/255.0 blue:210.0/255.0 alpha:1];
    // Do any additional setup after loading the view.
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    SettingVCCell *cell = (SettingVCCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingVCCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
//    cell.imageView.layer.cornerRadius = 20;
//    cell.imageView.layer.masksToBounds = YES;
    cell.titleLabel.text = [settingArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[settingImageArray objectAtIndex:indexPath.row]];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settingArray count];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0)
    {
        AboutVC *aboutVC = [[AboutVC alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
    else if (indexPath.row == 1)
    {
        InviteAFriendVC *inviteAFriendVC = [[InviteAFriendVC alloc] init];
        [self.navigationController pushViewController:inviteAFriendVC animated:YES];
    }
    else if (indexPath.row == 2)
    {
        SocialMediaVC *sociaMediaVC = [[SocialMediaVC alloc] init];
        [self.navigationController pushViewController:sociaMediaVC animated:YES];
    }
    else if (indexPath.row == 3)
    {
        GroupNameAndDetailVC *groupNameAndDetailVC = [[GroupNameAndDetailVC alloc] init];
        [self.navigationController pushViewController:groupNameAndDetailVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
