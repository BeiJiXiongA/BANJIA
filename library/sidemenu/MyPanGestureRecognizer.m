//
//  MyPanGestureRecognizer.m
//  BANJIA
//
//  Created by TeekerZW on 14/11/7.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "MyPanGestureRecognizer.h"

@interface MyPanGestureRecognizer () <UIGestureRecognizerDelegate>

@end

@implementation MyPanGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //获取点击坐标
    CGPoint pointPosition = [touch locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(self.responseFrame, pointPosition)) {
        return YES;
    }
    return NO;
}


@end

