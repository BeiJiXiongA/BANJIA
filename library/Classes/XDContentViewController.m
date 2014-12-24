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
#import "UINavigationController+JDSideMenu.h"


@class XDTabViewController;
//@class WelcomeViewController;
//@class KKNavigationController;


#define YSTART  (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)?0.0f:20.0f)

@interface XDContentViewController ()<UITextViewDelegate,ChatDelegate,MsgDelegate>

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
    
    DDLOG_CURRENT_METHOD;
    DDLOG(@"topViewControllerName++++%@",NSStringFromClass([[UIApplication sharedApplication].keyWindow.rootViewController class]));
//    NSString *topViewControllerName = NSStringFromClass([[self topViewControllerName] class]);
//    if ([topViewControllerName isEqualToString:@"JDSideMenu"])
    
    if ([[Tools user_id] length] > 0)
    {
        WelcomeViewController *login = [[WelcomeViewController alloc] init];
        KKNavigationController *loginNav = [[KKNavigationController alloc] initWithRootViewController:login];
        [[UIApplication sharedApplication].keyWindow setRootViewController:loginNav];
    }
}

//-(UIViewController *)topViewControllerName
//{
//    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (topViewController.presentedViewController)
//    {
//        topViewController = topViewController.presentedViewController;
//    }
//    DDLOG(@"topViewController+++ %@",NSStringFromClass([topViewController class]));
//    return topViewController;
//}

-(NSString *)topViewControllerName
{
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController)
    {
        topViewController = topViewController.presentedViewController;
    }
    NSString *topViewControllerName = @"";
    if ([NSStringFromClass([topViewController class]) isEqualToString:@"KKNavigationController"])
    {
        topViewControllerName = NSStringFromClass([((KKNavigationController *)topViewController).visibleViewController class]);
    }
    else if([NSStringFromClass([topViewController class]) isEqualToString:@"JDSideMenu"])
    {
        topViewControllerName = NSStringFromClass([((KKNavigationController *)[((JDSideMenu *)topViewController) contentController]).visibleViewController class]);
    }
    return topViewControllerName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postlogOut) name:@"logout" object:nil];
    
//    if ([[Tools user_id] length] > 0)
//    {
//        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
//        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
//    }
    
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
    
    [_navigationBarView addSubview:_navigationBarBg];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-90, YSTART + 3, 180, 36)];
    _titleLabel.font = Title_Font;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = TITLE_COLOR;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationBarView addSubview:_titleLabel];
    
    UITapGestureRecognizer *navtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCurrentVersion)];
    _titleLabel.userInteractionEnabled = YES;
    navtap.numberOfTapsRequired = 5;
    [_titleLabel addGestureRecognizer:navtap];
    
    returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, YSTART +13, 11, 18)];
    [returnImageView setImage:[UIImage imageNamed:@"icon_return"]];
    [self.navigationBarView addSubview:returnImageView];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, YSTART +2, 58 , NAV_RIGHT_BUTTON_HEIGHT)];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:BackButtonTitleColor forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(unShowSelfViewController) forControlEvents:UIControlEventTouchUpInside];
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    _backButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    
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

-(void)showCurrentVersion
{
    [Tools showTips:[NSString stringWithFormat:@"%@-%@",[Tools client_ver],[Tools bundleVerSion]] toView:self.bgView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (SYSVERSION >= 7)
    {
        NSString *visibleViewControllerName = NSStringFromClass([[self.navigationController visibleViewController] class]);
        if ([visibleViewControllerName isEqualToString:@"HomeViewController"] ||
            [visibleViewControllerName isEqualToString:@"MyClassesViewController"] ||
            [visibleViewControllerName isEqualToString:@"FriendsViewController"] ||
            [visibleViewControllerName isEqualToString:@"MessageViewController"] ||
            [visibleViewControllerName isEqualToString:@"PersonalSettingViewController"])
        {
            self.navigationController.sideMenuController.panGestureEnabled = YES;
        }
        else
        {
            self.navigationController.sideMenuController.panGestureEnabled = NO;
        }
        
        if ([visibleViewControllerName isEqualToString:@"MessageViewController"])
        {
            //在聊天列表界面
            [[NSUserDefaults standardUserDefaults] setObject:AT_MSGLIST forKey:VIEW_TYPE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            //不在聊天列表界面
            [[NSUserDefaults standardUserDefaults] setObject:NOT_AT_MSGLIST forKey:VIEW_TYPE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int subNum = [[ud objectForKey:NewChatMsgNum] intValue]+
    [[ud objectForKey:NewClassNum] intValue]+
    [[ud objectForKey:UCFRIENDSUM] intValue];
    if (subNum == 0)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    
}

-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [self viewWillAppear:NO];
}

-(void)dealNewMsg:(NSDictionary *)dict
{
    [self viewWillAppear:NO];
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
