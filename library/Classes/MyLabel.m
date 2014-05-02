//
//  MyLabel.m
//  School
//
//  Created by TeekerZW on 3/29/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "MyLabel.h"

@implementation MyLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 0, 0);
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 0, 0);
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
