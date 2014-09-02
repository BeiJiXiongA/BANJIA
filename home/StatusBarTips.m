//
//  StatusBarTips.m
//  BANJIA
//
//  Created by TeekerZW on 14/8/26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "StatusBarTips.h"
#import "MessageViewController.h"
#import "KKNavigationController.h"
#import "SideMenuViewController.h"

#define ICON_WIDTH 20
#define ICON_HEIGHT 20

#define TIPMESSAGE_TIGHT_MARGIN 20
#define ICON_RIGHT_MARGIN 5

@interface StatusBarTips ()
{
    UILabel *tipLabel;
    UIImageView *tipIcon;
    
    NSTimer *hideTimer;
}

@end

@implementation StatusBarTips
@synthesize tipsMessage,messageType,tipsDelegate,dataDict;

static StatusBarTips *tipsWindows = nil;

+(StatusBarTips *)shareTipsWindow
{
    if (!tipsWindows)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            tipsWindows = [[super allocWithZone:NULL] init];
        });
    }
    return tipsWindows;
}

-(id)init
{
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.frame = CGRectMake(SCREEN_WIDTH-120, 0, 200, 20);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.windowLevel = UIWindowLevelStatusBar +10;
        if (SYSVERSION >= 7.0)
        {
            self.backgroundColor = TIMECOLOR;
        }
        else
        {
            self.backgroundColor = [UIColor blackColor];
        }
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        
        tipIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, ICON_WIDTH, ICON_HEIGHT)];
        tipIcon.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        tipIcon.backgroundColor = [UIColor clearColor];
        [self addSubview:tipIcon];
        
        tipLabel = [[UILabel alloc] initWithFrame:self.bounds];
//#ifdef NSTextAlignmentRight
        tipLabel.textAlignment = NSTextAlignmentLeft;
        tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.font = [UIFont systemFontOfSize:12];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:tipLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipstap)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:<#(NSString *)#> object:<#(id)#>]
    }
    return self;
}

-(void)tipstap
{
    [self hideTips];
    if ([self.tipsDelegate respondsToSelector:@selector(tapTipsWithData:)])
    {
        [self.tipsDelegate tapTipsWithData:self.dataDict];
    }
}

-(void)showTips:(NSString *)tips
{
    if (hideTimer)
    {
        [hideTimer invalidate];
    }
    
    tipIcon.image = nil;
    tipIcon.hidden = YES;
    
    CGSize size = [tips sizeWithFont:tipLabel.font constrainedToSize:CGSizeMake(120, ICON_HEIGHT)];
    size.width += TIPMESSAGE_TIGHT_MARGIN;
    if (size.width >self.bounds.size.width - ICON_WIDTH)
    {
        size.width = self.bounds.size.width - ICON_WIDTH;
    }
    
    tipLabel.frame = CGRectMake(self.bounds.size.width, 0, size.width, self.bounds.size.height);
    tipLabel.text = tips;
    
    [self makeKeyAndVisible];
}
-(void)showTipsWithImage:(UIImage *)tipsImage message:(NSString *)message messageType:(NSString *)type tipDelegate:(id)delegate
{
    if (hideTimer)
    {
        [hideTimer invalidate];
    }
    
    self.messageType = type;
    
    CGSize size = [message sizeWithFont:tipLabel.font constrainedToSize:self.bounds.size];
    size.width += TIPMESSAGE_TIGHT_MARGIN;
    if (size.width > 90)
    {
        size.width = 90;
    }
    
    self.tipsDelegate = delegate;
    
    tipIcon.frame = CGRectMake(20, 2, ICON_WIDTH-4, ICON_HEIGHT-4);
    tipIcon.image = tipsImage;
    tipIcon.hidden = NO;
    
    tipLabel.frame = CGRectMake(tipIcon.frame.size.width+tipIcon.frame.origin.x+3, 0, size.width, ICON_HEIGHT);
    tipLabel.text = message;
    
    [self makeKeyAndVisible];
}

-(void)showTipsWithImage:(UIImage *)tipsImage message:(NSString *)message hideAfterDelay:(NSInteger)seconds
{
//    [self showTipsWithImage:tipsImage message:message messageType:@""];
    hideTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(hideTips) userInfo:nil repeats:NO];
}

-(void)hideTips
{
    self.hidden = YES;
    [self removeFromSuperview];
//    [self makeKeyWindow];
}

@end
