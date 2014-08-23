//
//  WelcomeViewController.m
//  School
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "WelcomeViewController.h"
#import "Header.h"
#import "RegistViewController.h"
#import "CustomSwitch.h"
#import "UIImageView+WebCache.h"
#import "SideMenuViewController.h"
#import "MyClassesViewController.h"
#import "HomeViewController.h"
#import "FillInfo2ViewController.h"
#import "KKNavigationController.h"
#import "SettingPasswordViewController.h"

#import "OtherLoginViewController.h"

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
    self.view.backgroundColor = [UIColor blackColor];
    self.backButton.hidden = YES;
    self.navigationBarView.hidden = YES;
    
    
    CGFloat logoImageHeight = 0;
    if (FOURS)
    {
        if (SYSVERSION >= 7.0)
        {
            logoImageHeight = 220;
            space = 5;
        }
        else
        {
            logoImageHeight = 200;
            space = 5;
        }
    }
    else
    {
        if (SYSVERSION >= 7.0)
        {
            logoImageHeight = 267;
            space = 15;
        }
        else
        {
            logoImageHeight = 247;
            space = 15;
        }
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
    phoneNumTextfield.font = [UIFont systemFontOfSize:18];
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
    passwordTextfield.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:passwordTextfield];

    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(28, passwordTextfield.frame.size.height+passwordTextfield.frame.origin.y+space,SCREEN_WIDTH-56, 42);
    [loginButton setTitle:@"手机号登录" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    loginButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [loginButton setTintColor:[[UIColor whiteColor]colorWithAlphaComponent:0.3]];
    [self.bgView addSubview:loginButton];
    
    UIButton *forgetPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPwdButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetPwdButton setBackgroundColor:[UIColor clearColor]];
    forgetPwdButton.frame = CGRectMake(loginButton.frame.size.width+loginButton.frame.origin.x-100, loginButton.frame.size.height+loginButton.frame.origin.y+8, 100, 20);
    forgetPwdButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [forgetPwdButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [forgetPwdButton addTarget:self action:@selector(forgetPwd) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:forgetPwdButton];
    
    UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH/2+1, 50);
    [otherButton setTitle:@"其他方式登录" forState:UIControlStateNormal];
    [otherButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    otherButton.titleLabel.font = [UIFont systemFontOfSize:18];
    otherButton.layer.borderColor = UIColorFromRGB(0xcdcdcd).CGColor;
    otherButton.layer.borderWidth = 1;
    [otherButton addTarget:self action:@selector(otherlogin) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:otherButton];
    
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-50, SCREEN_WIDTH/2, 50);
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [registButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    registButton.titleLabel.font = [UIFont systemFontOfSize:18];
    registButton.layer.borderColor = UIColorFromRGB(0xcdcdcd).CGColor;
    registButton.layer.borderWidth = 1;
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:registButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)otherlogin
{
    OtherLoginViewController *otherlogin = [[OtherLoginViewController alloc] init];
    [self.navigationController pushViewController:otherlogin animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)dealloc
{
    
}

-(void)forgetPwd
{
    SettingPasswordViewController *setpwd = [[SettingPasswordViewController alloc] init];
    setpwd.phoneNum = [Tools getPhoneNumFromString:phoneNumTextfield.text];
    setpwd.forgetPwd = YES;
    [self.navigationController pushViewController:setpwd animated:YES];
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
        NSString *userStr = @"";
        if ([[APService registrionID] length] > 0)
        {
            userStr = [APService registrionID];
//            [Tools showAlertView:userStr delegateViewController:nil];
        }
        
        NSDictionary *paraDict = @{@"phone":phoneNum,
                                   @"pwd":passwordTextfield.text,
                                   @"c_ver":[Tools client_ver],
                                   @"d_name":[Tools device_name],
                                   @"d_imei":[Tools device_uid],
                                   @"c_os":[Tools device_os],
                                   @"d_type":@"iOS",
                                   @"registrationID":userStr,
                                   @"account":@"0"
                                   };
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:MB_LOGIN];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
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
                
                if ([[dict objectForKey:@"opt"] isKindOfClass:[NSDictionary class]])
                {
                    [ud setObject:[[dict objectForKey:@"opt"] objectForKey:NewNoticeAlert] forKey:NewNoticeAlert];
                    [ud setObject:[[dict objectForKey:@"opt"] objectForKey:NewNoticeMotion] forKey:NewNoticeMotion];
                    [ud setObject:[[dict objectForKey:@"opt"] objectForKey:NewDiaryAlert] forKey:NewDiaryAlert];
                    [ud setObject:[[dict objectForKey:@"opt"] objectForKey:NewChatAlert] forKey:NewChatAlert];
                }
                else
                {
                    [ud setObject:@"1" forKey:NewNoticeAlert];
                    [ud setObject:@"1" forKey:NewNoticeMotion];
                    [ud setObject:@"1" forKey:NewDiaryAlert];
                    [ud setObject:@"1" forKey:NewChatAlert];
                }
            
                [ud synchronize];
                NSString *name = [dict objectForKey:@"r_name"];
                if ([name isEqualToString:ANONYMITY])
                {
                    FillInfo2ViewController *fillInfoVC = [[FillInfo2ViewController alloc] init];
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
            [Tools hideProgress:self.bgView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [Tools showProgress:self.bgView];
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
