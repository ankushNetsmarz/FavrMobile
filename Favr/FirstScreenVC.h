//
//  FirstScreenVC.h
//  Favr
//
//  Created by Taranjit Singh on 19/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessContactVC.h"

@interface FirstScreenVC : UIViewController <UIGestureRecognizerDelegate,AccessFBDelegate>

@property (weak, nonatomic) IBOutlet UIView *verfiedUserView;
@property(nonatomic, weak)IBOutlet UIView* slideUnlockView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserLogin;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrowInUnlockView;


@end
