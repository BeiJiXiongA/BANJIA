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
#import "KKNavigationController.h"
#import "WelcomeViewController.h"

//@class WelcomeViewController;
//@class KKNavigationController;


#define YSTART  (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)?0.0f:20.0f)

@interface XDContentViewController ()<UITextViewDelegate>

@end

@implementation XDContentViewController

@synthesize topbarImage,unReadLabel,returnImageView;

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

-(void)postlogOut
{
    [Tools exit];
    DDLOG_CURRENT_METHOD;
    WelcomeViewController *login = [[WelcomeViewController alloc] init];
    KKNavigationController *loginNav = [[KKNavigationController alloc] initWithRootViewController:login];
    [self.navigationController presentViewController:loginNav animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    DDLOG(@"version %@ screenheight %.1f==%.1f",[Tools device_version],SCREEN_HEIGHT,[UIScreen mainScreen].bounds.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postlogOut) name:@"logout" object:nil];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
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
    _navigationBarBg.backgroundColor = NavigationBgColor;
    _navigationBarBg.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_NAVIGATION_BAR_HEIGHT);
//    _navigationBarBg.image = [UIImage imageNamed:@"nav_bar_bg"];
    
    [_navigationBarView addSubview:_navigationBarBg];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-90, YSTART + 3, 180, 36)];
    _titleLabel.font = Title_Font;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = TITLE_COLOR;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationBarView addSubview:_titleLabel];
    
    returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, YSTART +13, 11, 18)];
    [returnImageView setImage:[UIImage imageNamed:@"icon_return"]];
    [self.navigationBarView addSubview:returnImageView];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, YSTART +2, 58 , NAV_RIGHT_BUTTON_HEIGHT)];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:BackButtonTitleColor forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(unShowSelfViewController) forControlEvents:UIControlEventTouchUpInside];
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _backButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    
    unReadLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, YSTART +13, 15, 15)];
    unReadLabel.backgroundColor = [UIColor redColor];
    unReadLabel.layer.cornerRadius = 7.5;
    unReadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    unReadLabel.layer.borderWidth = 2;
    unReadLabel.clipsToBounds = YES;
    unReadLabel.hidden = YES;
    [self.navigationBarView addSubview:unReadLabel];

    [_navigationBarView addSubview:_backButton];
    _bgView.backgroundColor = BgViewColor;
    [self.view addSubview:_bgView];
    
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
