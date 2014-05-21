//
//  HeaderVIew.m
//  BANJIA
//
//  Created by TeekerZW on 5/15/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "HeaderVIew.h"

#define TOP_BG_HIDE 120.0f
#define TOP_FLAG_HIDE 55.0f
#define RATE 2
#define SWITCH_Y -TOP_FLAG_HIDE
#define ORIGINAL_POINT CGPointMake(self.bounds.size.width/2, -20)

@implementation HeaderVIew
@synthesize headerDel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -TOP_BG_HIDE, self.bounds.size.width, self.bounds.size.height-TOP_BG_HIDE)];
        self.bgImageView.image = [UIImage imageNamed:@""];
        [self addSubview:self.bgImageView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scrollView];
        
        self.scrollView.backgroundColor = [UIColor yellowColor];
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;   //???
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, self.bounds.size.width, self.bounds.size.height-TOP_HEIGHT)];
        [self.scrollView addSubview:_contentView];
        
        self.contentView.backgroundColor = [UIColor orangeColor];
        
        _refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        self.refreshImageView.center = ORIGINAL_POINT;
        self.refreshImageView.image = [UIImage imageNamed:@"icon"];
        [self addSubview:self.refreshImageView];
        
        self.contentRect = self.contentView.bounds;
        
        [self prepare];
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    CGFloat rate = point.y/scrollView.contentSize.height;
    if (point.y+TOP_BG_HIDE > 5)
    {
        self.bgImageView.frame = CGRectMake(0, (-TOP_BG_HIDE)*(1+rate*RATE), self.bgImageView.frame.size.width, self.bgImageView.frame.size.height);
    }
    if (!_isLoading)
    {
        if (scrollView.dragging)
        {
            if (point.y+TOP_FLAG_HIDE >= 0)
            {
                self.refreshImageView.center = CGPointMake(self.refreshImageView.center.x, (-TOP_FLAG_HIDE)*(1+rate*RATE*8)+20);
            }
            self.refreshImageView.transform = CGAffineTransformMakeRotation(rate*30);
        }
        else
        {
            if (point.y < SWITCH_Y)
            {
                [self startRotate];
            }
            else
            {
                self.refreshImageView.center = CGPointMake(self.refreshImageView.center.x, (-TOP_FLAG_HIDE)*(1+rate*RATE*7)+20);
            }
        }
    }
}

-(void)prepare
{
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.scrollView.frame.size.height+1);
}
-(void)setRefreshImage:(UIImage *)image
{
    if (image)
    {
        self.bgImageView.image = image;
        CGSize size = image.size;
        CGRect rect = self.bgImageView.frame;
        rect.size.width = self.bounds.size.width;
        rect.size.height = self.bounds.size.width*(size.height/size.width);
        self.bgImageView.frame = rect;
    }
}

-(void)setBgImage:(UIImage *)image
{
    if (image)
    {
        self.bgImageView.image = image;
        CGSize size  =image.size;
        CGRect rect = self.bgImageView.frame;
        rect.size.width = self.bounds.size.width;
        rect.size.height = self.bounds.size.width * (size.height/size.width);
        self.bgImageView.frame = rect;
    }
}
-(void)setContentView:(UIView *)contentView
{
    if (contentView)
    {
        _contentView = contentView;
        [self.contentView addSubview:contentView];
    }
}
-(void)startRotate
{
    _isLoading = YES;
    stopRatating = NO;
    angle = 0;
    if ([self.headerDel respondsToSelector:@selector(refreshAction)])
    {
        [self.headerDel refreshAction];
    }
}
-(void)endUpdate
{
    stopRatating = YES;
}
-(void)rotateRefreshImage
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle*(M_PI/180.f));
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.refreshImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        angle += 10;
        if (!stopRatating)
        {
            [self rotateRefreshImage];
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.refreshImageView.center = ORIGINAL_POINT;
            } completion:^(BOOL finished) {
                _isLoading = NO;
            }];
        }
    }];
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
