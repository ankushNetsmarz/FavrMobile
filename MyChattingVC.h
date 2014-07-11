//
//  MyChattingVC.h
//  Favr
//
//  Created by Taranjit Singh on 01/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "Quickblox/Quickblox.h"

@interface MyChattingVC : UIViewController<HPGrowingTextViewDelegate>

@property (nonatomic, strong) QBUUser *opponent;
@property (nonatomic, strong) QBChatRoom *chatRoom;
@property (nonatomic,strong) HPGrowingTextView* textView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property(nonatomic,weak)IBOutlet UINavigationBar* navBar;
@property(nonatomic,strong)UIViewController* prevVC;

@end