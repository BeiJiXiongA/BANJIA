//
//  MoreViewController.h
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol moreDelegate <NSObject>

-(void)signOutClass:(BOOL)signOut;

@end

@interface MoreViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, strong) id<moreDelegate> signOutDel;
@end
