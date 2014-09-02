//
//  SideMenuViewController.h
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@interface SideMenuViewController : XDContentViewController
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *buttonTableView;

-(void)statusTipTapWithDataDict:(NSDictionary *)dataDict;
@end
