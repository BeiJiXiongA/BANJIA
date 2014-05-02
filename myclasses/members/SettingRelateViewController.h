//
//  SettingRelateViewController.h
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SetRelateDel <NSObject>

-(void)changePareTitle:(NSString *)title;

@end

@interface SettingRelateViewController : XDContentViewController
@property (nonatomic, strong) NSString *parentName;
@property (nonatomic, strong) NSString *parentID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL admin;
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, strong) id<SetRelateDel> setRelate;
@end
