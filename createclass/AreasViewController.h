//
//  AreasViewController.h
//  BANJIA
//
//  Created by TeekerZW on 5/16/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SelectAreaDelegate <NSObject>

-(void)selectAreaWithDict:(NSDictionary *)dict;

@end

@interface AreasViewController : XDContentViewController
@property (nonatomic, strong) NSArray *areaArray;
@property (nonatomic, strong) id<SelectAreaDelegate> selectAreaDel;
@property (nonatomic, assign) BOOL fromCreate;
@end
