//
//  PopView.m
//  MyProject
//
//  Created by TeekerZW on 14-6-6.
//  Copyright (c) 2014年 ZW. All rights reserved.
//

#import "PopView.h"

@implementation PopView
@synthesize orientation,point,radius,hei,wid;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        orientation = PopOrientationDown;
        radius = 5;
        point = CGPointMake(self.frame.size.width/2-radius, 0);
        hei = 5;
        wid = 0;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
//    CGSize size = self.bounds.size;
//    
//    CGFloat margin = 0;
    
    [[[UIColor blackColor]colorWithAlphaComponent:0.5] set];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    
    
    [path moveToPoint:CGPointMake(point.x, point.y)];
    if (orientation == PopOrientationDown)
    {
        [path addLineToPoint:CGPointMake(point.x+radius+wid, point.y+radius+hei)];
        [path addLineToPoint:CGPointMake(self.frame.size.width-radius, point.y+radius+hei)];
        [path addArcWithCenter:CGPointMake(self.frame.size.width-radius, point.y+radius*2+hei) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height-radius)];
        [path addArcWithCenter:CGPointMake(self.frame.size.width-radius, self.frame.size.height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [path addLineToPoint:CGPointMake(radius, self.frame.size.height)];
        [path addArcWithCenter:CGPointMake(radius, self.frame.size.height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [path addLineToPoint:CGPointMake(0, radius*2)];
        [path addArcWithCenter:CGPointMake(radius, radius*2+hei) radius:radius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
        [path addLineToPoint:CGPointMake(point.x-radius-wid, point.y+radius+hei)];
        [path addLineToPoint:point];
        
    }
    
//    CGFloat scale = floor((MIN(size.height, size.width)-margin) / 4);
//    
//    CGAffineTransform transform;
//    transform = CGAffineTransformMakeScaleTranslate(scale,scale,size.width/2,size.height/2);
//    
//    [path applyTransform:transform];
    [path closePath];
    [path fill];
    
//    path.lineWidth = 0.5;
//    [[UIColor grayColor] set];
//    [path stroke];
}

//static inline CGAffineTransform CGAffineTransformMakeScaleTranslate(CGFloat sx,CGFloat sy,
//                                                                    CGFloat dx,CGFloat dy)
//{
//    return CGAffineTransformMake(sx,0.f,0.f,sy,dx,dy);
//}


@end
