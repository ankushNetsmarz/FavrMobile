//
//  ViewController.h
//  ChatAppSelfTut
//
//  Created by Taranjit on 24/06/14.
//  Copyright (c) 2014 Taranjit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersPaginator.h"
#import "Quickblox/Quickblox.h"

@interface ChatSharedManager : NSObject <QBChatDelegate,QBActionStatusDelegate, NMPaginatorDelegate>

+(id)sharedManager;

@property (nonatomic, strong) NSMutableArray *chatUsers;
@property (nonatomic, strong) NSString *txtUserName;
@property (nonatomic, strong) NSString *txtUserPassword;


- (void)initializeChatInstance;
- (void)refreshChatSession;
- (void)loginChatFunction:(NSString*)login_Register;
@end
