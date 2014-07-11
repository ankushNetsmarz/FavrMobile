//
//  ContactsData.h
//  PanSelfTut
//
//  Created by Taranjit on 29/05/14.
//  Copyright (c) 2014 Taranjit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsData : NSObject
@property(nonatomic)NSString* firstNames;
@property(nonatomic)NSString* lastNames;
@property(nonatomic)UIImage* image;
@property(nonatomic)NSMutableArray* numbers;
@property(nonatomic)NSMutableArray* emails;
@end
