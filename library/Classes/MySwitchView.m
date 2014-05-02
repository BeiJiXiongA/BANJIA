//
//  MySwitchView.m
//  School
//
//  Created by TeekerZW on 14-1-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "MySwitchView.h"
#import "Header.h"

@implementation MySwitchView
@synthesize leftView,rightView,selectView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
        leftView.backgroundColor = LIGHT_BLUE_COLOR;
        leftView.layer.borderColor = [UIColor blackColor].CGColor;
        leftView.layer.borderWidth = 1.0f;
        [self addSubview:leftView];
        
        rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height)];
        rightView.layer.borderColor = [UIColor blackColor].CGColor;
        rightView.layer.borderWidth = 1.0f;
        rightView.backgroundColor = LIGHT_BLUE_COLOR;
        [self addSubview:rightView];
        
        selectView = [[UIView alloc] init];
        selectView.layer.borderWidth = 0.5f;
        selectView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        selectView.backgroundColor = [UIColor whiteColor];
        [self addSubview:selectView];
        
        UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectClick)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:selectTap];
        
    }
    return self;
}

-(void)selectClick
{
    if (![self isOpen])
    {
        [UIView animateWithDuration:0.2f animations:^{
            selectView.center = CGPointMake(self.frame.size.width/4, self.frame.size.height/2);
        }];
//        leftView.backgroundColor = TITLE_COLOR;
//        rightView.backgroundColor = LIGHT_BLUE_COLOR;
    }
    else
    {
//        leftView.backgroundColor = LIGHT_BLUE_COLOR;
//        rightView.backgroundColor = TITLE_COLOR;
        [UIView animateWithDuration:0.2f animations:^{
            selectView.center = CGPointMake(self.frame.size.width/4*3, self.frame.size.height/2);
        }];
    }
    if ([self.mySwitchDel respondsToSelector:@selector(switchStateChanged:)])
    {
        [self.mySwitchDel switchStateChanged:self];
    }
}

-(BOOL)isOpen
{
    if (selectView.frame.origin.x == self.frame.size.width/2)
    {
        return NO;
    }
    return YES;
}

-(void)close
{
    if (![self isOpen])
    {
        if ([self.mySwitchDel respondsToSelector:@selector(switchStateChanged:)])
        {
            [self.mySwitchDel performSelector:@selector(switchStateChanged:) withObject:self];
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            selectView.center = CGPointMake(self.frame.size.width/4, self.frame.size.height/2);
        }];
    }
}

-(void)open
{
    if ([self.mySwitchDel respondsToSelector:@selector(switchStateChanged:)])
    {
        [self.mySwitchDel performSelector:@selector(switchStateChanged:) withObject:self];
    }
    if ([self isOpen])
    {
        [UIView animateWithDuration:0.2f animations:^{
            selectView.center = CGPointMake(self.frame.size.width/4*3, self.frame.size.height/2);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
