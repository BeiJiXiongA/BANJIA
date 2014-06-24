//
//  MyButton.m
//  BANJIA
//
//  Created by TeekerZW on 6/11/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton
@synthesize iconImageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        iconImageView = [[UIImageView alloc] init];
        [self addSubview:iconImageView];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}


@end
