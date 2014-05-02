//
//  CustomSwitch.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "CustomSwitch.h"

@implementation CustomSwitch
@synthesize on;
@synthesize tintColor,leftLabel,rightLabel,clippingView;

+(CustomSwitch *)switchWithLeftText:(NSString *)leftText
                       andRightText:(NSString *)rightText
{
    CustomSwitch *switchView = [[CustomSwitch alloc] initWithFrame:CGRectZero];
    
    switchView.leftLabel.text = leftText;
    switchView.rightLabel.text = rightText;
    
    return switchView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 95, 27)];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

-(void)loadView
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self setThumbImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self setMinimumTrackImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self setMaximumTrackImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    self.minimumValue = 0;
    self.maximumValue = 1;
    self.continuous = NO;
    
    self.on = NO;
    self.value = 0.0;
    
    self.clippingView = [[UIView alloc] initWithFrame:CGRectMake(4, 2, 87, 23)];
    self.clippingView.clipsToBounds = YES;
    self.clippingView.userInteractionEnabled = NO;
    self.clippingView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.clippingView];
    
    NSString *leftLabelText = NSLocalizedString(@"ON","Custom UISwitch ON label. If localized to empty string then I/O will be used");
    if ([leftLabelText length] == 0)
    {
        leftLabelText = @"1";
    }
    
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.frame = CGRectMake(0, 0, 48, 23);
    self.leftLabel.text = leftLabelText;
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.leftLabel.font = [UIFont boldSystemFontOfSize:17];
    self.leftLabel.textColor = [UIColor whiteColor];
    [self.clippingView addSubview:leftLabel];
    
    
    NSString *rightLabelText = NSLocalizedString(@"OFF","Custom UISwitch OFF label. If localized to empty string then I/O will be used");
    if ([rightLabelText length] == 0)
    {
        rightLabelText = @"O";  // use helvetica uppercase o to be a 0.
    }
    
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.frame = CGRectMake(95, 0, 48, 23);
    self.rightLabel.text = rightLabelText;
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.font = [UIFont boldSystemFontOfSize:17];
    self.rightLabel.textColor = [UIColor grayColor];
    self.rightLabel.backgroundColor = [UIColor clearColor];
    //      self.rightLabel.shadowColor = [UIColor redColor];
    //      self.rightLabel.shadowOffset = CGSizeMake(0,0);
    [self.clippingView addSubview:self.rightLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //  NSLog(@"leftLabel=%@",NSStringFromCGRect(self.leftLabel.frame));
    
    // move the labels to the front
    [self.clippingView removeFromSuperview];
    [self addSubview:self.clippingView];
    
    CGFloat thumbWidth = self.currentThumbImage.size.width;
    CGFloat switchWidth = self.bounds.size.width;
    CGFloat labelWidth = switchWidth - thumbWidth;
    CGFloat inset = self.clippingView.frame.origin.x;
    
    //  NSInteger xPos = self.value * (self.bounds.size.width - thumbWidth) - (self.leftLabel.frame.size.width - thumbWidth/2);
    NSInteger xPos = self.value * labelWidth - labelWidth - inset;
    self.leftLabel.frame = CGRectMake(xPos, 0, labelWidth, 23);
    
    //  xPos = self.value * (self.bounds.size.width - thumbWidth) + (self.rightLabel.frame.size.width - thumbWidth/2);
    xPos = switchWidth + (self.value * labelWidth - labelWidth) - inset;
    self.rightLabel.frame = CGRectMake(xPos, 0, labelWidth, 23);
    
    //  NSLog(@"value=%f    xPos=%i",self.value,xPos);
    //  NSLog(@"thumbWidth=%f    self.bounds.size.width=%f",thumbWidth,self.bounds.size.width);
}

- (UIImage *)image:(UIImage*)image tintedWithColor:(UIColor *)tint
{
    
    if (tint != nil)
    {
        UIGraphicsBeginImageContext(image.size);
        
        //draw mask so the alpha is respected
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGImageRef maskImage = [image CGImage];
        CGContextClipToMask(currentContext, CGRectMake(0, 0, image.size.width, image.size.height), maskImage);
        CGContextDrawImage(currentContext, CGRectMake(0,0, image.size.width, image.size.height), image.CGImage);
        
        [image drawAtPoint:CGPointMake(0,0)];
        [tint setFill];
        UIRectFillUsingBlendMode(CGRectMake(0,0,image.size.width,image.size.height),kCGBlendModeColor);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    else
    {
        return image;
    }
}

-(void)setTintColor:(UIColor*)color
{
    if (color != tintColor)
    {
        [self setMinimumTrackImage:[self image:[UIImage imageNamed:@"switchBlueBg.png"] tintedWithColor:tintColor] forState:UIControlStateNormal];
    }
    
}

- (void)setOn:(BOOL)turnOn animated:(BOOL)animated;
{
    on = turnOn;
    
    if (animated)
    {
        [UIView  beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
    }
    
    if (on)
    {
        self.value = 1.0;
    }
    else
    {
        self.value = 0.0;
    }
    
    if (animated)
    {
        [UIView commitAnimations];
    }
}

- (void)setOn:(BOOL)turnOn
{
    [self setOn:turnOn animated:NO];
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"preendTrackingWithtouch");
    [super endTrackingWithTouch:touch withEvent:event];
    NSLog(@"postendTrackingWithtouch");
    m_touchedSelf = YES;
    
    [self setOn:on animated:YES];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touchesBegan");
    m_touchedSelf = NO;
    on = !on;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"touchesEnded");
    
    if (!m_touchedSelf)
    {
        [self setOn:on animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
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
