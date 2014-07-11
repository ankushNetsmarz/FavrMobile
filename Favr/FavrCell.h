//
//  FavrCell.h
//  Favr
//
//  Created by Taranjit Singh on 16/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableArray+SWUtilityButtons.h"
#import "SWTableViewCell.h"

@interface FavrCell : SWTableViewCell

@property (weak, nonatomic)IBOutlet UILabel *lblFavrNo;
@property (weak, nonatomic)IBOutlet UIImageView *imgFavrPic;
@property (weak, nonatomic)IBOutlet UILabel *lblFavrName;
@property (weak, nonatomic)IBOutlet UIButton *btnInfo;
@end
