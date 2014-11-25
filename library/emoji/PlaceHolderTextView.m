//
//  PlaceHolderTextView.m
//  BANJIA
//
//  Created by TeekerZW on 14/11/14.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "PlaceHolderTextView.h"

@implementation PlaceHolderTextView
-(id)initWithFrame:(CGRect)frame placeHolder:(NSString *)placeholder
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.textView.text = placeholder;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.editable = NO;
        self.textView.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.textView];
        [self sendSubviewToBack:self.textView];
        self.delegate = self;
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
