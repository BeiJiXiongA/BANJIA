//
//  MyTextField.m
//  FaceDemo
//
//  Created by TeekerZW on 3/27/14.
//
//

#import "MyTextField.h"

@implementation MyTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.background = [[UIImage imageNamed:@"input"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return self;
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 20, 0);
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 20, 0);
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
