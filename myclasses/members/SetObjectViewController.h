//
//  SetObjectViewController.h
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SetObjectDelegate <NSObject>

-(void)setobject:(NSString *)objectUpdate;

@end

@interface SetObjectViewController : XDContentViewController
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) id<SetObjectDelegate> setobject;
@end
