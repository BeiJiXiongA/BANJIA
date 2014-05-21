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
#import "UIImageView+WebCache.h"
#import "SideMenuViewController.h"
#import "MyClassesViewController.h"
#import "FillInfoViewController.h"

#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@class AppDelegate;

@interface WelcomeViewController ()<UITextViewDelegate,UIAlertViewDelegate>
{
    CGFloat logoY;
    int sexure;
    int reg;
    NSMutableDictionary *accountDict;
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
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    reg = 0;    
    self.backButton.hidden = YES;
    self.stateView.hidden = YES;
    self.navigationBarView.hidden = YES;
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = logoImage;
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-logoImage.size.width)/2,SCREEN_HEIGHT, logoImage.size.width, logoImage.size.height);
    logoImageView.alpha = 0;
    
    [self.bgView addSubview:logoImageView];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(10, SCREEN_HEIGHT-250.5, 186, 38);
    [loginButton setTitle:@"手机号登陆" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    loginButton.alpha = 0;
    loginButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [loginButton setTitleColor:UIColorFromRGB(0x898989) forState:UIControlStateNormal];
    [loginButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [self.bgView addSubview:loginButton];
    
    
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(loginButton.frame.origin.x+loginButton.frame.size.width+3, SCREEN_HEIGHT-250.5, SCREEN_WIDTH-loginButton.frame.size.width-20-3, 38);
    [registButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [registButton setTitleColor:UIColorFromRGB(0x898989) forState:UIControlStateNormal];
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    registButton.alpha = 0;
    [self.bgView addSubview:registButton];
    
    UIButton *sinaLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sinaLoginButton.backgroundColor = [UIColor clearColor];
    sinaLoginButton.frame = CGRectMake(10, SCREEN_HEIGHT-200, SCREEN_WIDTH-20, 40);
    [sinaLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    sinaLoginButton.alpha = 0;
    sinaLoginButton.tag=100;
    [sinaLoginButton setImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
    [self.bgView addSubview:sinaLoginButton];
    
    UIButton *qqLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qqLoginButton.backgroundColor = [UIColor clearColor];
    qqLoginButton.frame = CGRectMake(10, SCREEN_HEIGHT-145, SCREEN_WIDTH-20, 40);
    [qqLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    qqLoginButton.alpha = 0;
    qqLoginButton.tag=101;
    [qqLoginButton setImage:[UIImage imageNamed:@"QQ"] forState:UIControlStateNormal];
    [self.bgView addSubview:qqLoginButton];
    
    UIButton *renrenLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    renrenLoginButton.backgroundColor = [UIColor clearColor];
    renrenLoginButton.frame = CGRectMake(10, SCREEN_HEIGHT-95, SCREEN_WIDTH-20, 40);
    [renrenLoginButton setImage:[UIImage imageNamed:@"renren"] forState:UIControlStateNormal];
    [renrenLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    renrenLoginButton.alpha = 0;
    renrenLoginButton.tag=102;
    [self.bgView addSubview:renrenLoginButton];
    
    logoY = 0;
    if (FOURS)
    {
        logoY=40;
    }
    else
    {
        logoY = 85;
    }
    
    [UIView animateWithDuration:1.0 animations:^{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loginAccount
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
                                   DDLOG(@"success==%@",[userInfo sourceData]);
                                   
                                   accountDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                                   [accountDict setObject:[userInfo uid] forKey:@"a_id"];
                                   [accountDict setObject:[userInfo nickname] forKey:@"nickname"];
                                   [accountDict setObject:[userInfo profileImage] forKey:@"header_icon"];
                                   if (loginID == ShareTypeSinaWeibo)
                                   {
                                       //sina
                                       
                                       [accountDict setObject:@"sw" forKey:@"a_type"];
                                       
                                       [self loginWithName:[userInfo nickname]];
                                   }
                                   else if(loginID == ShareTypeQQSpace)
                                   {
                                       //qq
                                      
                                       [accountDict setObject:@"qq" forKey:@"a_type"];
                                       [self loginWithName:[userInfo nickname]];
                                   }
                                   else if(loginID == ShareTypeRenren)
                                   {
                                       //ren ren
                                       
                                       DDLOG(@"rrnickname  %@",RRNICKNAME);
                                       [accountDict setObject:@"rr" forKey:@"a_type"];
                                       [self loginWithName:[userInfo nickname]];
                                   }
                               }
                               else
                               {
                                   DDLOG(@"faile==%@==%ld==%d",[error errorDescription],(long)[error errorCode],[error errorLevel]);
                               }
                           }];
    
}

-(void)loginWithName:(NSString *)name   //AccountID:(NSString *)accountID accountType:(NSString *)accountType andName:(NSString *)name
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"a_id":[accountDict objectForKey:@"a_id"],
                                                                      @"a_type":[accountDict objectForKey:@"a_type"],
                                                                      @"c_ver":[Tools client_ver],
                                                                      @"d_name":[Tools device_name],
                                                                      @"d_imei":[Tools device_uid],
                                                                      @"c_os":[Tools device_os],
                                                                      @"d_type":@"iOS",
                                                                      @"p_cid":channelStr,
                                                                      @"p_uid":userStr,
                                                                      @"r_name":name,
                                                                      @"sex":@"1",
                                                                      @"reg":[NSString stringWithFormat:@"%d",reg]
                                                                      } API:LOGINBYAUTHOR];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"account login responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[dict objectForKey:@"u_id"] forKey:USERID];
                if ([Tools isPhoneNumber:[dict objectForKey:@"phone"]])
                {
                    [ud setObject:[dict objectForKey:@"phone"] forKey:PHONENUM];
                }
                [ud setObject:[dict objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [ud setObject:[dict objectForKey:@"img_icon"] forKey:HEADERIMAGE];
                [ud setObject:[dict objectForKey:@"r_name"] forKey:USERNAME];
                [ud setObject:[dict objectForKey:@"opt"] forKey:@"useropt"];
                
                NSString *a_type = [accountDict objectForKey:@"a_type"];
                if ([a_type isEqualToString:@"qq"])
                {
                    [ud setObject:name forKey:QQNICKNAME];
                }
                else if([a_type isEqualToString:@"rr"])
                {
                    [ud setObject:name forKey:RRNICKNAME];
                }
                else if([a_type isEqualToString:@"sw"])
                {
                     [ud setObject:name forKey:SINANICKNAME];
                }
                
                [ud synchronize];
                
                if (reg == 1)
                {
                    FillInfoViewController *fillInfo = [[FillInfoViewController alloc] init];
                    fillInfo.headerIcon = [accountDict objectForKey:@"header_icon"];
                    fillInfo.accountID = [accountDict objectForKey:@"a_id"];
                    fillInfo.accountType = [accountDict objectForKey:@"a_type"];
                    fillInfo.account = @"1";
                    fillInfo.nickName = [accountDict objectForKey:@"nickname"];
                    [self.navigationController pushViewController:fillInfo animated:YES];
                }
                else
                {
                    SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                    MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
                    JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesViewController menuController:sideMenuViewController];
                    [self presentViewController:sideMenu animated:YES completion:^{
                        
                    }];
                }
                
            }
            else if([[responseDict objectForKey:@"code"] intValue] == 0 && [[[responseDict objectForKey:@"message"] objectForKey:@"NO_THE_ACCOUNT"] length]>0)
            {
                reg = 1;
                [self  loginWithName:name];
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

-(void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.account = @"0";
    [self.navigationController pushViewController:loginViewController animated:YES];
}

-(void)regist
{
    RegistViewController *registViewController = [[RegistViewController alloc] init];
    [self.navigationController pushViewController:registViewController animated:YES];
}

@end
