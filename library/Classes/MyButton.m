//
//  MyButton.m
//  BANJIA
//
//  Created by TeekerZW on 6/11/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton
@synthesize iconImage,backgroudimage,iconRect;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setlayout
{
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:iconRect];
    [iconImageView setImage:iconImage];
    [self addSubview:iconImageView];
    [self setBackgroundImage:backgroudimage forState:UIControlStateNormal];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
