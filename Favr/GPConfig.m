//
//  GPConfig.m
//  GPlusSelfTut
//
//  Created by Taranjit Singh on 07/06/14.
//  Copyright (c) 2014 Taranjit Singh. All rights reserved.
//

#import "GPConfig.h"

@implementation GPConfig
static GPConfig *sharedInstance = nil;

+ (GPConfig *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[GPConfig alloc] init];
    }
    return sharedInstance;
}
@end
