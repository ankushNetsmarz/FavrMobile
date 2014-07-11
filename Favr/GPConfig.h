//
//  GPConfig.h
//  GPlusSelfTut
//
//  Created by Taranjit Singh on 07/06/14.
//  Copyright (c) 2014 Taranjit Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPConfig : NSObject
@property(nonatomic, assign) BOOL useNativeSharebox;
// The text to prefill the user comment in the share dialog.
@property(nonatomic, strong) NSString *sharePrefillText;
// The array of people IDs to prefill the share dialog.
@property(nonatomic, strong) NSArray *sharePrefillPeople;
// The URL resource to share in the share dialog.
@property(nonatomic, strong) NSString *shareURL;

// Media elements to be attached. Only one will be used; |attachmentImage| has more priority.
@property(nonatomic, strong) UIImage *attachmentImage;
@property(nonatomic, strong) NSURL *attachmentVideoURL;

// Returns shared instance of |ShareConfiguration| class.
+ (GPConfig *)sharedInstance;

@end
