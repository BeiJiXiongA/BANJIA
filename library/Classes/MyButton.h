//
//  MyButton.h
//  BANJIA
//
//  Created by TeekerZW on 6/11/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyButton : UIButton
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *backgroudimage;
@property (nonatomic) CGRect iconRect;

-(void)setlayout;
@end
