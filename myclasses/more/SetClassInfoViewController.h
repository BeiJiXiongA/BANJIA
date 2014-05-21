//
//  SetClassInfoViewController.h
//  BANJIA
//
//  Created by TeekerZW on 5/12/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SetClassInfoDel <NSObject>

-(void)updateClassInfo:(NSString *)infoKey value:(NSString *)infoValue;

@end

@interface SetClassInfoViewController : XDContentViewController
@property (nonatomic, strong) NSString *infoKey;
@property (nonatomic, strong) NSString *infoStr;
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, assign) id<SetClassInfoDel> setClassInfoDel;
@end
