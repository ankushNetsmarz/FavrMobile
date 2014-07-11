//
//  AccessContactVC.h
//  Favr
//
//  Created by Taranjit Singh on 03/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccessFBDelegate <NSObject>

-(void)accessedUserFBAccountSuccessfully:(BOOL)success;

@end


@interface AccessContactVC : NSObject
@property(nonatomic,strong)NSArray* userContacts;

+(id)sharedManager;

@property(nonatomic,strong)NSString* userFBEmail;
@property(nonatomic,strong)NSString* userFBName;
@property(nonatomic,strong)UIImage* userFBImage;
@property(nonatomic,strong)NSString* userFBID;
@property(nonatomic,strong)NSString* fbAccessToken;
@property(nonatomic, weak)id<AccessFBDelegate> delegate;
-(void)fetchContacts;
-(void)inviteNonFriends;
- (void)requestFacebookAccessFirstTime;

@end
