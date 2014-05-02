//
//  WelcomeViewController.m
//  School
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "WelcomeViewController.h"
#import "Header.h"
#import "LoginViewController.h"
#import "RegistViewController.h"
#import "CustomSwitch.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "SideMenuViewController.h"
#import "MyClassesViewController.h"

@class AppDelegate;

@interface WelcomeViewController ()<UITextViewDelegate>
{
    CGFloat logoY;
}
@end

@implementation WelcomeViewController

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
	// Do any additional setup after loading the view.
    
    self.backButton.hidden = YES;
    self.stateView.hidden = YES;
    self.navigationBarView.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = logoImage;
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-logoImage.size.width)/2,SCREEN_HEIGHT, logoImage.size.width, logoImage.size.height);
    logoImageView.alpha = 0;
    [self.bgView addSubview:logoImageView];
    
    //CGRectMake((SCREEN_WIDTH-logoImage.size.width)/2,UI_NAVIGATION_BAR_HEIGHT+40, logoImage.size.width, logoImage.size.height);
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
//    UIImage *loginImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(10, SCREEN_HEIGHT-297.5, 186, 38);
    [loginButton setTitle:@"手机号登陆" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    loginButton.alpha = 0;
    loginButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [loginButton setTitleColor:UIColorFromRGB(0x898989) forState:UIControlStateNormal];
    [loginButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [self.bgView addSubview:loginButton];
    
    
//    UIImage *registImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg_green"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(loginButton.frame.origin.x+loginButton.frame.size.width+3, SCREEN_HEIGHT-297.5, SCREEN_WIDTH-loginButton.frame.size.width-20-3, 38);
    [registButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [registButton setTitleColor:UIColorFromRGB(0x898989) forState:UIControlStateNormal];
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    registButton.alpha = 0;
    [self.bgView addSubview:registButton];
    
    UIButton *sinaLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sinaLoginButton.backgroundColor = [UIColor clearColor];
    sinaLoginButton.frame = CGRectMake(10, SCREEN_HEIGHT-230, SCREEN_WIDTH-20, 40);
    [sinaLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    sinaLoginButton.alpha = 0;
    sinaLoginButton.tag=100;
    [sinaLoginButton setImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
    [self.bgView addSubview:sinaLoginButton];
    
    UIButton *qqLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qqLoginButton.backgroundColor = [UIColor clearColor];
    qqLoginButton.frame = CGRectMake(10, SCREEN_HEIGHT-175, SCREEN_WIDTH-20, 40);
    [qqLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    qqLoginButton.alpha = 0;
    qqLoginButton.tag=101;
    [qqLoginButton setImage:[UIImage imageNamed:@"QQ"] forState:UIControlStateNormal];
    [self.bgView addSubview:qqLoginButton];
    
    UIButton *renrenLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    renrenLoginButton.backgroundColor = [UIColor clearColor];
    renrenLoginButton.frame = CGRectMake(10, SCREEN_HEIGHT-125, SCREEN_WIDTH-20, 40);
    [renrenLoginButton setImage:[UIImage imageNamed:@"renren"] forState:UIControlStateNormal];
    [renrenLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    renrenLoginButton.alpha = 0;
    renrenLoginButton.tag=102;
    [self.bgView addSubview:renrenLoginButton];
    
    logoY = 0;
    if (FOURS)
    {
        logoY=20;
    }
    else
    {
        logoY = 85;
    }
    
    [UIView animateWithDuration:1.5 animations:^{
        logoImageView.alpha = 1;
        logoImageView.frame = CGRectMake((SCREEN_WIDTH-(logoImage.size.width+2.5))/2, logoY, logoImage.size.width+5, logoImage.size.height+5);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            sinaLoginButton.alpha = 1;
            registButton.alpha = 1;
            loginButton.alpha = 1;
            renrenLoginButton.alpha = 1;
            qqLoginButton.alpha = 1;
        }];
    }];
    
}
static int loginID;
- (void)clickedThirdLoginButton:(UIButton *)button{
    
    switch (button.tag-100) {
        case 0:
            loginID=1;
            
            break;
        case 1:
            loginID=6;
            
            break;
        case 2:
            loginID=7;
            break;
            
        default:
            break;
    }
    //[ShareSDK cancelAuthWithType:loginID];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    [ShareSDK getUserInfoWithType:loginID
                      authOptions:authOptions
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error){
       if (result)
       {
           DDLOG(@"success==%@",[userInfo uid]);
           if (loginID == ShareTypeSinaWeibo)
           {
               //sina
           }
           else if(loginID == ShareTypeQQSpace)
           {
               //qq
               [self loginWithAccountID:[userInfo uid] accountType:@"qq"];
           }
           else if(loginID == ShareTypeRenren)
           {
               //ren ren
               [self loginWithAccountID:[userInfo uid] accountType:@"rr"];
           }
       }
       else
       {
           DDLOG(@"faile==%@==%d==%d",[error errorDescription],[error errorCode],[error errorLevel]);
       }
       
       //                               [ShareSDK cancelAuthWithType:loginID];
    }];
    //                           [ShareSDK cancelAuthWithType:loginID];
    
}

-(void)loginWithAccountID:(NSString *)accountID  accountType:(NSString *)accountType
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *channelStr,*userStr;
    
    id channel = [ud objectForKey:BPushRequestChannelIdKey];
    if (channel == nil)
    {
        channelStr = @"0";
    }
    else
    {
        channelStr = [ud objectForKey:BPushRequestChannelIdKey];
    }
    id user_id = [ud objectForKey:BPushRequestUserIdKey];
    
    if (user_id == nil)
    {
        userStr = @"0";
    }
    else
    {
        userStr = [ud objectForKey:BPushRequestUserIdKey];
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"a_id":accountID,
                                                                      @"a_type":accountType,
                                                                      @"c_ver":[Tools client_ver],
                                                                      @"d_name":[Tools device_name],
                                                                      @"d_imei":[Tools device_uid],
                                                                      @"c_os":[Tools device_os],
                                                                      @"d_type":@"iOS",
                                                                      @"p_cid":channelStr,
                                                                      @"p_uid":userStr
                                                                      } API:@"/users/mbLoginByAnother"];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"account login responsedict %@",responseString);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[dict objectForKey:@"u_id"] forKey:USERID];
                [ud setObject:[dict objectForKey:@"phone"] forKey:PHONENUM];
                [ud setObject:[dict objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [ud setObject:[dict objectForKey:@"img_icon"] forKey:HEADERIMAGE];
                [ud setObject:[dict objectForKey:@"r_name"] forKey:USERNAME];
                [ud setObject:[dict objectForKey:@"opt"] forKey:@"useropt"];
                [ud synchronize];
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesViewController menuController:sideMenuViewController];
                [self presentViewController:sideMenu animated:YES completion:^{
                    
                }];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[[[responseDict objectForKey:@"message"] allValues] firstObject] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置密码", nil];
                [al show];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [loginViewController showSelfViewController:self];
}

-(void)regist
{
    RegistViewController *registViewController = [[RegistViewController alloc] init];
    [registViewController showSelfViewController:self];
}

@end
