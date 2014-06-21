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
#import "HomeViewController.h"
#import "FillInfoViewController.h"
#import "KKNavigationController.h"
#import "SettingPasswordViewController.h"

#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define NOPWDTAG   787878

@class AppDelegate;

@interface WelcomeViewController ()<
UITextViewDelegate,
UIAlertViewDelegate,
UITextFieldDelegate>
{
    CGFloat logoY;
    int sexure;
    int reg;
    NSMutableDictionary *accountDict;
    
    UIScrollView *mainScrollview;
    
    UITextField *phoneNumTextfield;
    UITextField *passwordTextfield;
    NSString *phoneNum;
    
    NSString *account;
    NSString *accountID;
    NSString *accountType;
    
    CGFloat space;
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
    self.view.backgroundColor = [UIColor blackColor];
    reg = 0;    
    self.backButton.hidden = YES;
    self.stateView.hidden = YES;
    self.navigationBarView.hidden = YES;
    
    
    CGFloat logoImageHeight = 0;
    if (FOURS)
    {
        logoImageHeight = 230;
        space = 5;
    }
    else
    {
        logoImageHeight = 247;
        space = 15;
    }
    UIView *headerView = [[UIView alloc] init];\
    headerView.frame = CGRectMake(0,0, SCREEN_WIDTH, logoImageHeight);
    headerView.backgroundColor = RGB(59, 189, 100, 1);
    [self.bgView addSubview:headerView];
    
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = logoImage;
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-logoImage.size.width)/2+10,(logoImageHeight-logoImage.size.height)/2
                                     +20, logoImage.size.width, logoImage.size.height);
    logoImageView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:logoImageView];
    
    UIImage *bancaImage = [UIImage imageNamed:@"icon"];
    UIImageView *bancaImageView = [[UIImageView alloc] init];
    bancaImageView.image = bancaImage;
    bancaImageView.frame = CGRectMake(SCREEN_WIDTH-80, logoImageHeight-bancaImage.size.height, bancaImage.size.width,bancaImage.size.height);
    bancaImageView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:bancaImageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
//    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(28, headerView.frame.size.height+headerView.frame.origin.y+space, SCREEN_WIDTH-56, 43)];
    phoneNumTextfield.backgroundColor = [UIColor whiteColor];
    phoneNumTextfield.delegate = self;
    phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumTextfield.tag = 1000;
    phoneNumTextfield.background = nil;
    phoneNumTextfield.layer.cornerRadius = 3;
    phoneNumTextfield.textColor = TITLE_COLOR;
    phoneNumTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    phoneNumTextfield.background = inputImage;
    phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:PHONE_FORMAT placeholderCharacter:'*'];
    phoneNumTextfield.placeholder = @"手机号码";
    [self.bgView addSubview:phoneNumTextfield];
    
    if ([[Tools last_phone_num] length] > 0)
    {
        phoneNumTextfield.text = [Tools last_phone_num];
    }
    
    passwordTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(28, phoneNumTextfield.frame.origin.y+phoneNumTextfield.frame.size.height+space, SCREEN_WIDTH-56, 42)];
    passwordTextfield.backgroundColor = [UIColor whiteColor];
    passwordTextfield.delegate = self;
    passwordTextfield.background = nil;
    passwordTextfield.layer.cornerRadius = 3;
    passwordTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextfield.secureTextEntry = YES;
    passwordTextfield.placeholder = @"密码";
    passwordTextfield.textColor = TITLE_COLOR;
//    passwordTextfield.background = inputImage;
    passwordTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextfield.tag = 1001;
    [self.bgView addSubview:passwordTextfield];

    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(28, passwordTextfield.frame.size.height+passwordTextfield.frame.origin.y+space,SCREEN_WIDTH-56, 42);
    [loginButton setTitle:@"手机号登陆" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    loginButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [loginButton setTintColor:[[UIColor whiteColor]colorWithAlphaComponent:0.3]];
    [self.bgView addSubview:loginButton];
    
    UIButton *forgetPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPwdButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetPwdButton setBackgroundColor:[UIColor clearColor]];
    forgetPwdButton.frame = CGRectMake(loginButton.frame.size.width+loginButton.frame.origin.x-100, loginButton.frame.size.height+loginButton.frame.origin.y+5, 100, 20);
    forgetPwdButton.titleLabel.font = [UIFont systemFontOfSize:12];
    forgetPwdButton.titleLabel.textColor = TITLE_COLOR;
    [forgetPwdButton addTarget:self action:@selector(forgetPwd) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:forgetPwdButton];
    
    
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(SCREEN_WIDTH-130, 10, 120, 38);
//    [registButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [registButton setTitle:@"注册新账号>>" forState:UIControlStateNormal];
    registButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [registButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:registButton];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, loginButton.frame.origin.y+loginButton.frame.size.height+25+space, 100, 30)];
    tipLabel.text = @"其他方式登录";
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];
    
    UIButton *sinaLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sinaLoginButton.backgroundColor = [UIColor clearColor];
    sinaLoginButton.frame = CGRectMake(120, loginButton.frame.origin.y+loginButton.frame.size.height+20+space, 47, 47);
    [sinaLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    sinaLoginButton.tag=100;
    [sinaLoginButton setImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
    [self.bgView addSubview:sinaLoginButton];
    
    UIButton *qqLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qqLoginButton.backgroundColor = [UIColor clearColor];
    qqLoginButton.frame = CGRectMake(180, loginButton.frame.origin.y+loginButton.frame.size.height+20+space, 47, 47);
    [qqLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    qqLoginButton.tag=101;
    [qqLoginButton setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    [self.bgView addSubview:qqLoginButton];
    
    UIButton *renrenLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    renrenLoginButton.backgroundColor = [UIColor clearColor];
    renrenLoginButton.frame = CGRectMake(240, loginButton.frame.origin.y+loginButton.frame.size.height+20+space, 47, 47);
    [renrenLoginButton setImage:[UIImage imageNamed:@"rr"] forState:UIControlStateNormal];
    [renrenLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    renrenLoginButton.tag=102;
    [self.bgView addSubview:renrenLoginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)forgetPwd
{
    if ([phoneNumTextfield.text length] <= 0)
    {
        [Tools showAlertView:@"请填写手机号码" delegateViewController:nil];
        return ;
    }
    if (![Tools isPhoneNumber:[Tools getPhoneNumFromString:phoneNumTextfield.text]])
    {
        [Tools showAlertView:@"手机号格式不正确" delegateViewController:nil];
        return ;
    }
    SettingPasswordViewController *setpwd = [[SettingPasswordViewController alloc] init];
    setpwd.phoneNum = [Tools getPhoneNumFromString:phoneNumTextfield.text];
    setpwd.forgetPwd = YES;
    [self.navigationController pushViewController:setpwd animated:YES];
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
    
    NSString *userStr = @"simu";
    if ([[APService registrionID] length] > 0)
    {
        userStr = [APService registrionID];
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
                                                                      @"p_cid":@"123",
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
                    HomeViewController *homeViewController = [[HomeViewController alloc] init];
                    KKNavigationController *homeNav = [[KKNavigationController alloc] initWithRootViewController:homeViewController];
                    JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:homeNav menuController:sideMenuViewController];
                    [self.navigationController presentViewController:sideMenu animated:YES completion:^{
                        
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
    if ([phoneNumTextfield.text length] == 0)
    {
        [Tools showAlertView:@"手机号不能为空！" delegateViewController:nil];
        return ;
    }
    phoneNum = [Tools getPhoneNumFromString:phoneNumTextfield.text];
    if (![Tools isPhoneNumber:phoneNum])
    {
        [Tools showAlertView:@"手机号格式不正确！" delegateViewController:nil];
        return ;
    }
    
    if ([passwordTextfield.text length] == 0)
    {
        [Tools showAlertView:@"密码不能为空" delegateViewController:nil];
        return ;
    }
    if (![Tools isPassWord:passwordTextfield.text])
    {
        [Tools showAlertView:@"密码由6-12位数字和字母组成！" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        NSString *userStr = @"simu";
        if ([[APService registrionID] length] > 0)
        {
            userStr = [APService registrionID];
        }
        
        NSDictionary *paraDict = @{@"phone":phoneNum,
                                   @"pwd":passwordTextfield.text,
                                   @"c_ver":[Tools client_ver],
                                   @"d_name":[Tools device_name],
                                   @"d_imei":[Tools device_uid],
                                   @"c_os":[Tools device_os],
                                   @"d_type":@"iOS",
                                   @"p_cid":@"123",
                                   @"p_uid":userStr,
                                   @"account":@"0"
                                   };
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:MB_LOGIN];
        
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"login responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[dict objectForKey:@"u_id"] forKey:USERID];
                [ud setObject:phoneNum forKey:PHONENUM];
                [ud setObject:passwordTextfield.text forKey:PASSWORD];
                [ud setObject:[dict objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [ud setObject:[dict objectForKey:@"img_icon"] forKey:HEADERIMAGE];
                [ud setObject:[dict objectForKey:@"r_name"] forKey:USERNAME];
                [ud setObject:[dict objectForKey:@"opt"] forKey:@"useropt"];
                [ud synchronize];
                NSString *name = [dict objectForKey:@"r_name"];
                if ([name isEqualToString:@"anonymity"])
                {
                    FillInfoViewController *fillInfoVC = [[FillInfoViewController alloc] init];
                    fillInfoVC.fromRoot = YES;
                    KKNavigationController *fillNav = [[KKNavigationController alloc] initWithRootViewController:fillInfoVC];
                    [self.navigationController presentViewController:fillNav animated:YES completion:nil];
                }
                else
                {
                    [ud setObject:[dict objectForKey:@"sex"] forKey:USERSEX];
                    [ud setObject:[dict objectForKey:@"img_icon"] forKey:HEADERIMAGE];
                    [ud setObject:[dict objectForKey:@"r_name"] forKey:USERNAME];
                }
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                HomeViewController *homeViewController = [[HomeViewController alloc] init];
                KKNavigationController *homeNav = [[KKNavigationController alloc] initWithRootViewController:homeViewController];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:homeNav menuController:sideMenuViewController];
                [self.navigationController presentViewController:sideMenu animated:YES completion:nil];
            }
            else
            {
                if ([[[[responseDict objectForKey:@"message"] allKeys] firstObject] isEqualToString:@"NO_PASSWORD"])
                {
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[[[responseDict objectForKey:@"message"] allValues] firstObject] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置密码", nil];
                    al.tag = NOPWDTAG;
                    [al show];
                }
                else
                {
                    [Tools dealRequestError:responseDict fromViewController:nil];
                }
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NOPWDTAG)
    {
        if (buttonIndex == 1)
        {
            SettingPasswordViewController *setPw = [[SettingPasswordViewController alloc] init];
            setPw.phoneNum = phoneNum;
            setPw.forgetPwd =  NO;
            [self.navigationController pushViewController:setPw animated:YES];
        }
    }
}


//-(void)login
//{
//    
//    LoginViewController *loginViewController = [[LoginViewController alloc] init];
//    loginViewController.account = @"0";
//    [self.navigationController pushViewController:loginViewController animated:YES];
//}

-(void)regist
{
    RegistViewController *registViewController = [[RegistViewController alloc] init];
    [self.navigationController pushViewController:registViewController animated:YES];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-height+80);
    }completion:^(BOOL finished) {
    }];

    
}



@end
