//
//  LoginViewController.m
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "XDContentViewController.h"
#import "AppDelegate.h"
#import "MyColor.h"
#import "Header.h"

#define YSTART  (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)?0.0f:20.0f)

@interface XDContentViewController ()<UITextViewDelegate>

@end

@implementation XDContentViewController

@synthesize topbarImage,unReadLabel,returnImageView;

- (void)HandlePan:(UIPanGestureRecognizer *)recognizer{
    
    
    
    CGPoint delta = [recognizer translationInView : self.parentViewController.view];
    float proportion = [[UIScreen mainScreen] bounds].size.width - recognizer.view.frame.origin.x;
    float ratio = proportion / ([[UIScreen mainScreen] bounds].size.width);  //变化的比率
    float alpha = XD_SHADOWVIEW_MAX_ALPHA * ratio;                //self移动后阴影层的透明度
    XDContentViewController * xdParentContent = (XDContentViewController*)self.parentViewController;

    if (recognizer.state == UIGestureRecognizerStateBegan )
    {
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.alpha =  XD_SHADOWVIEW_MAX_ALPHA;
        [self.parentViewController.view addSubview:_shadowView];
        [self.parentViewController.view bringSubviewToFront:self.view];
//        [self.view bringSubviewToFront:_shadowView];
        UIView *view = self.parentViewController.view ;
        NSLog(@"%f %f  %f %f", view.frame.origin.x, view.frame.origin.y
              ,view.frame.size.width, view.frame.size.height);

    }
    else if(recognizer.state == UIGestureRecognizerStateChanged )
    {
 
        CGRect parentRect = CGRectMake(XD_SHADOWVIEW_ORGION_MAX_X * ratio,
                                       XD_SHADOWVIEW_ORGION_MAX_Y * ratio,
                                       UI_SCREEN_WIDTH - XD_SHADOWVIEW_ORGION_MAX_X * ratio * 1.5,
                                       UI_MAINSCREEN_HEIGHT - XD_SHADOWVIEW_ORGION_MAX_Y * ratio * 1.5);
        
        CGPoint c = self.view.frame.origin;
        c.x += delta.x;
        if (c.x > 0) {
            [UIView animateWithDuration:0.01 animations:^{
                self.view.frame = CGRectMake(c.x, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
                xdParentContent.bgView.frame = parentRect;
                _shadowView.alpha = alpha;
            }];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateFailed)
    {
 
        if (recognizer.view.frame.origin.x > XD_SHADOWVIEW_DECIDE_DIRECTIONPOINT ) {
            
            [self unShowSelfViewController];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH,
                                             UI_MAINSCREEN_HEIGHT);
                
                CGRect rcView = CGRectMake(XD_SHADOWVIEW_ORGION_MAX_X,
                                           XD_SHADOWVIEW_ORGION_MAX_Y,
                                           UI_SCREEN_WIDTH - XD_SHADOWVIEW_ORGION_MAX_X * 2 ,
                                           UI_MAINSCREEN_HEIGHT - XD_SHADOWVIEW_ORGION_MAX_Y * 2);

                
                [xdParentContent.bgView setFrame:rcView];
                _shadowView.alpha = XD_SHADOWVIEW_MAX_ALPHA;
            }completion:^(BOOL finished) {
                _shadowView.alpha = 0;
                [_shadowView removeFromSuperview];
                
            }];
        }
    }
    [recognizer setTranslation:CGPointZero inView:self.parentViewController.view];
}

- (void)setRecognierEnable:(BOOL)isEnable
{
    if (isEnable) {
        panGestureRecognier = [[UIPanGestureRecognizer alloc]
                               initWithTarget:self
                               action:@selector(HandlePan:)];
        
        [self.view addGestureRecognizer:panGestureRecognier];

    }else{
        [self.view removeGestureRecognizer:panGestureRecognier];
    }
}

- (void)unShowSelfViewController
{

}


-(void)showSelfViewController: (XDContentViewController*) parentViewCon
{
    
}

#pragma -mark lifeCycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, YSTART,
                                                       UI_SCREEN_WIDTH,
                                                       UI_SCREEN_HEIGHT)];
    

    _navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 UI_SCREEN_WIDTH,
                                                                 UI_NAVIGATION_BAR_HEIGHT)];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT,
                                                              UI_SCREEN_WIDTH,
                                                              UI_MAINSCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT)];
    [_bgView addSubview:_contentView];
    [_bgView addSubview:_navigationBarView];
    

    _navigationBarBg = [[UIImageView alloc] init];
    _navigationBarBg.backgroundColor = UIColorFromRGB(0xffffff);
    _navigationBarBg.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_NAVIGATION_BAR_HEIGHT);
    _navigationBarBg.image = [UIImage imageNamed:@"nav_bar_bg"];
    [_navigationBarView addSubview:_navigationBarBg];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-90, 8, 180, 36)];
    _titleLabel.font = [UIFont fontWithName:@"Courier" size:19];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = UIColorFromRGB(0x666464);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationBarView addSubview:_titleLabel];
    
    
    returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 15, UI_NAVIGATION_BAR_HEIGHT-20)];
    [returnImageView setImage:[UIImage imageNamed:@"icon_return"]];
    [self.navigationBarView addSubview:returnImageView];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 60 , UI_NAVIGATION_BAR_HEIGHT-10)];
    [_backButton setTitle:@"  返回" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:UIColorFromRGB(0x727171) forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(unShowSelfViewController) forControlEvents:UIControlEventTouchUpInside];
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _backButton.titleLabel.font = [UIFont systemFontOfSize:17];
    
    unReadLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 13, 15, 15)];
    unReadLabel.backgroundColor = [UIColor redColor];
    unReadLabel.layer.cornerRadius = 7.5;
    unReadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    unReadLabel.layer.borderWidth = 2;
    unReadLabel.clipsToBounds = YES;
    unReadLabel.hidden = YES;
    [self.navigationBarView addSubview:unReadLabel];

    [_navigationBarView addSubview:_backButton];
    _bgView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    [self.view addSubview:_bgView];
    
    _stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    _stateView.backgroundColor = [UIColor whiteColor];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion intValue] >= 7.0)
    {
        [self.view addSubview:_stateView];
    }
//    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;//系统默认不支持旋转功能
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *v in _bgView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]] || [v isKindOfClass:[UITextView class]])
        {
            if (![v isExclusiveTouch])
            {
                [v resignFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    self.bgView.center = CENTER_POINT;
                }completion:^(BOOL finished) {
                    
                }];
            }
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
}

@end
