//
//  AccountVCCell.m
//  Favr
//
//  Created by Ankush on 26/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "AccountVCCell.h"

@implementation AccountVCCell
@synthesize imageView, titleLabel, statusBtn, infoButton, statusImageView;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
