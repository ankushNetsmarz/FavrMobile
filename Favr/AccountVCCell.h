//
//  AccountVCCell.h
//  Favr
//
//  Created by Ankush on 26/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountVCCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *statusBtn;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

@end
