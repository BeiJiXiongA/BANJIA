//
//  SelectCityViewController.h
//  BANJIA
//
//  Created by TeekerZW on 5/16/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SelectCitydelegate <NSObject>

-(void)selectCityWithDict:(NSDictionary *)cityDict;

@end

@interface SelectCityViewController : XDContentViewController
@property (nonatomic, assign)  id<SelectCitydelegate> selectCityDel;
@end
